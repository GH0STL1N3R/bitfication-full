class DepositsController < ApplicationController
  DEPOSIT_COMMISSION_RATE = BigDecimal("0.01")
  
  respond_to :html, :json
  
  def new
    
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
      @deposit.build_bank_account
      fetch_bank_accounts
    end
    
  end
  
  def create
    
    @currencies_deposit = Currency.where('code != ?', "btc")
    
    @deposit_rate = DEPOSIT_COMMISSION_RATE
    
    @deposit = Deposit.from_params(params[:deposit])
    
    @deposit.account = current_user
    
    @deposit.bank_account.user_id = current_user.id
    
    # build operation
    @deposit.build_operation
    
    @deposit.save
    
    unless @deposit.new_record?
      respond_with do |format|
        format.html do
          redirect_to new_account_deposit_path,
            :notice => I18n.t("deposits.index.successful.#{@deposit.state}", :amount => @deposit.amount.abs, :currency => @deposit.currency, :deposit_link => "#{view_context.link_to(I18n.t("deposits.index.successful.bank_details"), new_account_deposit_path)}")
        end
          
        format.json { render :json => @deposit }
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
