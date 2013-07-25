class Deposit < AccountOperation 
  include ActionView::Helpers::NumberHelper
  include ActiveRecord::Transitions
  
  DEPOSIT_COMMISSION_RATE = BigDecimal("0.01")
  
  attr_accessible :bank_account_id, :bank_account_attributes

  belongs_to :account

  #accepts_nested_attributes_for :bank_account
  
  #before_validation :check_bank_account_id

  validates :currency,
    :inclusion => { :in => ["BRL"] }
  
  validates :amount,
    :numericality => true,
    :minimal_amount => true
    #:negative => false
    
  state_machine do
    state :pending
    state :processed

    event :process do
      transitions :to => :processed,
        :from => :pending
    end
  end
  
  def self.from_params(params)
    deposit = class_for_transfer(params[:currency]).new(params)
   
    if deposit.amount
      deposit.amount = deposit.amount.abs 
    end
    
    deposit
  end
  
  def self.class_for_transfer(currency)
    currency = currency.to_s.downcase.to_sym
    self
  end
  
  def execute
    
    raise 'executing'
    
    # Charge a fee for deposits
    deposit_fee = BigDecimal(self.amount) * DEPOSIT_COMMISSION_RATE
      
    storage_amount = BigDecimal(self.amount)
    
    self.amount = self.amount - deposit_fee
    
    Operation.transaction do

      o = self.operation
      o.account_operations << self
      
      o.account_operations << AccountOperation.new do |ao|
        ao.amount = - storage_amount
        ao.currency = self.currency
        ao.account = Account.storage_account_for(self.currency)
      end
      
      o.account_operations << AccountOperation.new do |fee|
        fee.currency = self.currency
        fee.amount = deposit_fee
        fee.account = Account.storage_account_for(:fees)
      end
      
      raise(ActiveRecord::Rollback) unless o.save
      
    end
    
  end

  def check_bank_account_id
    if bank_account_id && account.bank_accounts.find(bank_account_id).blank?
      raise "Someone is trying to pull something fishy off"
    end
  end
  
  def deposit_after_fee
    
    if self.amount > 0
      # deduct fee
      number_with_delimiter((1- DEPOSIT_COMMISSION_RATE) * self.amount , :delimiter => ',')
    else
      self.amount
    end
    
  end
  
  def withdrawal_after_fee
  end
  
end
