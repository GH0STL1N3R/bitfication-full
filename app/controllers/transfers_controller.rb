class TransfersController < ApplicationController
  WITHDRAWAL_COMMISSION_RATE = BigDecimal("0.01")
  
  respond_to :html, :json
  
  def index
    @transfers = current_user.account_operations.paginate(:page => params[:page], :per_page => 16)
    respond_with @transfers
  end

  def new
    if ["BRL", "USD"].include? params[:currency]
      @transfer = WireTransfer.new(:currency => params[:currency])
      @transfer.build_bank_account
      fetch_bank_accounts
    else 
      # default currency
      if params[:currency].nil?
        @transfer = Transfer.new(:currency => "BTC")
      else
        @transfer = Transfer.new(:currency => params[:currency])
      end
    end
  end
  
  def show
    @transfer = current_user.account_operations.find(params[:id])
    respond_with @transfer
  end
  
  def create
    @transfer = Transfer.from_params(params[:transfer])
    @transfer.account = current_user
    
    #raise @transfer.to_yaml
    
    #debug(@transfer)
    
    if @transfer.is_a?(WireTransfer) && @transfer.bank_account
      @transfer.bank_account.user_id = current_user.id
      
      # Charge a fee for withdrawals
      withdrawal_fee = BigDecimal(params[:transfer][:amount]) * WITHDRAWAL_COMMISSION_RATE
      
      storage_amount = BigDecimal(params[:transfer][:amount]) - withdrawal_fee
      
      #transfer_amount = @transfer.amount
    else
      
      storage_amount = BigDecimal(params[:transfer][:amount])
      
    end
    
    #   514.8
    # 51480.0
    #-50965.2
    
    #puts withdrawal_fee
    
    #puts storage_amount
    
    #puts @transfer.amount
    
    #exit
    
    Operation.transaction do
      #debugger
      o = Operation.create!
      o.account_operations << @transfer
      
      o.account_operations << AccountOperation.new do |ao|
        ao.amount = storage_amount
        ao.currency = @transfer.currency
        ao.account = Account.storage_account_for(@transfer.currency)
      end
      
      # Charge a fee for withdrawals
      if @transfer.is_a?(WireTransfer) && @transfer.bank_account
        o.account_operations << AccountOperation.new do |fee|
          fee.currency = @transfer.currency
          fee.amount = withdrawal_fee
          fee.account = Account.storage_account_for(:fees)
        end
      end
      
      raise(ActiveRecord::Rollback) unless o.save
    end

    unless @transfer.new_record?
      respond_with do |format|
        format.html do
          redirect_to account_transfers_path,
            :notice => I18n.t("transfers.index.successful.#{@transfer.state}", :amount => @transfer.amount.abs, :currency => @transfer.currency)
        end
          
        format.json { render :json => @transfer }
      end
    else
      fetch_bank_accounts
      render :action => :new
    end
  end
  
  
  protected
  
  def fetch_bank_accounts
    @bank_accounts = current_user.bank_accounts.map { |ba| [ba.bank_name + " : " + ba.ag + " / " + ba.cc, ba.id] }
  end
end
