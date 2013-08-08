class Admin::PendingTransfersController < Admin::AdminController
  
  active_scaffold :account_operation do |config|
    config.actions = [:list, :show, :nested]
    
    config.columns = [
      :id,
      :account,
      :amount,
      :currency,
      :type,
      :created_at,
      :address
    ]
    
    config.columns << [:withdrawal_after_fee, :deposit_after_fee, :attachment]
    config.columns[:withdrawal_after_fee].label = 'Withdrawal After Fee'
    
    config.action_links.add 'process_tx', 
      :label => 'Mark processed', 
      :type => :member, 
      :method => :post,
      :position => false
      
    config.action_links.add 'cancel_tx', 
      :label => 'Cancel', 
      :type => :member, 
      :method => :post,
      :position => false,
      :confirm => "Are you sure?"
      #:dhtml_confirm => DHTMLConfirm.new
        #ModalboxConfirm.new
    
    #config.nested.add_link(:bank_account, :label => "Bank Account", :page => true) 
    
    #config.list.hide_nested_column = true
    
  end
  
  
  def conditions_for_collection
    ["state = 'pending' AND currency IN (#{current_user.allowed_currencies.map { |c| "'#{c.to_s.upcase}'" }.join(",")},'BTC')"]
  end
  
  def process_tx
    Deposit;Transfer;WireTransfer;BitcoinTransfer
    
    @record = AccountOperation.where("currency IN (#{current_user.allowed_currencies.map { |c| "'#{c.to_s.upcase}'" }.join(",")},'BTC')").
      find(params[:id])
    
    @record.process!
    
    if @record.type == "BitcoinTransfer"
      @record.execute
    end
    
    if @record.type == "Transfer" || @record.type == "WireTransfer" 
      UserMailer.withdrawal_processed_notification(@record).deliver
    end
    
    if @record.type == "Deposit"
      UserMailer.deposit_processed_notification(@record).deliver
    end
      
    render :template => 'admin/pending_transfers/process_tx'
  end
  
  def cancel_tx
    @record = AccountOperation.where("currency IN (#{current_user.allowed_currencies.map { |c| "'#{c.to_s.upcase}'" }.join(",")},'BTC')").
      find(params[:id])
    
    # time-saving advice: already tried putting this in the various models.. it didn't work
    @record.operation.account_operations.destroy_all
      
    render :template => 'admin/pending_transfers/process_tx'
  end
end
