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
    
    #@deposit.bank_account.user_id = current_user.id
    
    # build operation
    @deposit.build_operation
    
    @deposit.save
    
    @account_id = current_user.name
    
    unless @deposit.new_record?
      get_deposit_account
      
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
  end
end
