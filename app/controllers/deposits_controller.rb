class DepositsController < ApplicationController
  DEPOSIT_COMMISSION_RATE = BigDecimal("0.01")
  
  respond_to :html, :json
  
  def new
    
    @bank_account = BankAccount.new
    
    #debugger
    
    @currencies_deposit = Currency.where('code != ?', "btc")
    
    @deposit_rate = DEPOSIT_COMMISSION_RATE
    
    
    #default currency
    if params[:currency].nil?
      currency = "BRL"
    else
      currency = params[:currency]
    end
    
    if ["BRL"].include? currency
      @deposit = Deposit.new(:currency => params[:currency])
    end
    
    get_deposit_account
    
  end
  
  def create
    
    @currencies_deposit = Currency.where('code != ?', "btc")
    
    @deposit_rate = DEPOSIT_COMMISSION_RATE
    
    @deposit = Deposit.from_params(params[:deposit])
    
    @deposit.account = current_user
    
    @account_id = current_user.name
    
    # Calculate fee for deposits
    deposit_fee = @deposit.amount * DEPOSIT_COMMISSION_RATE
      
    storage_amount = @deposit.amount
    
    @deposit.amount = @deposit.amount - deposit_fee
    
    Operation.transaction do

      o = Operation.create!
      o.account_operations << @deposit
      
      o.account_operations << AccountOperation.new do |ao|
        ao.amount = (storage_amount * -1)
        ao.currency = @deposit.currency
        ao.account = Account.storage_account_for(@deposit.currency)
      end
      
      # Charge a fee for depoists
      o.account_operations << AccountOperation.new do |fee|
        fee.currency = @deposit.currency
        fee.amount = deposit_fee
        fee.account = Account.storage_account_for(:fees)
      end
           
      raise(ActiveRecord::Rollback) unless o.save
    end
    
    unless @deposit.new_record?
      
      get_deposit_account
      
      calc_before_after_fee(@deposit)
      
      # dispatch email to user
      #UserMailer.deposit_request_notification(@deposit).deliver
      
      respond_with do |format|
        format.html { render :action => "show" }
        format.json { render :json => @deposit }
      end
    else
      render :action => :new
    end
  end
  
  def show
    
    @deposit = Deposit.first
    
    calc_before_after_fee(@deposit)
    
    get_deposit_account
    
  end
  
  protected
  
  def fetch_bank_accounts
    @bank_accounts = current_user.bank_accounts.map { |ba| [ba.bank_name + " : " + ba.ag + " / " + ba.cc, ba.id] }
  end
  
  def get_deposit_account
    bank_account = YAML::load(File.open(File.join(Rails.root, "config", "banks.yml")))
    
    if bank_account
      bank_account = bank_account[Rails.env]
      @ag = bank_account["ag"]
      @cc = bank_account["cc"]
      @cnpj = bank_account["cnpj"]
      @bic = bank_account["bic"]
      @iban = bank_account["iban"]
      @bank = bank_account["bank"]
      @bank_address = bank_account["bank_address"]
      @account_holder = bank_account["account_holder"]
      @account_holder_address = bank_account["account_holder_address"]
    end
    
    #@user = current_user
    
  end
  
  def calc_before_after_fee(deposit)
    
    @deposit_beforefee = '%.0f' % (deposit.amount * (1 + DEPOSIT_COMMISSION_RATE)) 
    
    @deposit_afterfee =  '%.0f' % deposit.amount
    
  end
  
end
