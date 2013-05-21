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
    
    config.columns << :withdrawal_after_fee
    config.columns[:withdrawal_after_fee].label = 'Withdrawal After Fee'
    
    config.action_links.add 'process_tx', 
      :label => 'Mark processed', 
      :type => :member, 
      :method => :post,
      :position => false
    
    #config.nested.add_link(:bank_account, :label => "Bank Account", :page => true) 
    
    #config.list.hide_nested_column = true
    
  end
  
  
  def conditions_for_collection
    ["state = 'pending' AND currency IN (#{current_user.allowed_currencies.map { |c| "'#{c.to_s.upcase}'" }.join(",")},'BTC')"]
  end
  
  def process_tx
    Transfer;WireTransfer;LibertyReserveTransfer;BitcoinTransfer
    
    @record = Transfer.where("currency IN (#{current_user.allowed_currencies.map { |c| "'#{c.to_s.upcase}'" }.join(",")},'BTC')").
      find(params[:id])
    
    @record.process!
    
    if @record.type == "BitcoinTransfer"
      @record.execute
    end
    
    UserMailer.withdrawal_processed_notification(@record).deliver
    
    render :template => 'admin/pending_transfers/process_tx'
  end
end
