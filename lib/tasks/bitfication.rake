namespace :bitfication do
  desc "Update exchange statistics"
  task :stats => :environment do
    
    currency = "brl"
    
    @ticker = {
      :high => Trade.with_currency(currency).last_24h.maximum(:ppc),
      :low => Trade.with_currency(currency).last_24h.minimum(:ppc),
      :volume => (Trade.with_currency(currency).last_week.sum(:traded_btc) || 0),
      :last_trade => Trade.with_currency(currency).count.zero? ? 0 : {
        :at => Trade.with_currency(currency).plottable(currency).last.created_at.to_i,
        :price => Trade.with_currency(currency).plottable(currency).last.ppc
      }
    }
    
    # weighted average http://en.wikipedia.org/wiki/Mean#Weighted_arithmetic_mean
    w = 0
    wx = 0
    Trade.with_currency(currency).last_24h.each do |t|
      w += t.traded_btc.to_f
      wx += t.traded_btc.to_f * t.ppc.to_f
    end
    
    @ticker[:wavg] = wx / w
    
    # update db
    s = Stats.find_by_id(1)
    
    s.volume = @ticker[:volume]
    s.phigh = @ticker[:high]
    s.plow = @ticker[:low]
    s.pwavg = @ticker[:wavg]
    s.save
    
  end

end