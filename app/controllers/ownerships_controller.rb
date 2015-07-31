class OwnershipsController < ApplicationController
  before_action :logged_in_user

  def create
    if params[:asin]
      @item = Item.find_or_initialize_by(asin: params[:asin])
    else
      @item = Item.find(params[:item_id])
    end

    # itemsテーブルに存在しない場合はAmazonのデータを登録する。
    if @item.new_record?
      # TODO 商品情報の取得 Amazon::Ecs.item_lookupを用いてください
      response = {}
      amazon_item       = response.items.first
      @item.title        = amazon_item.get('ItemAttributes/Title')
      @item.small_image  = amazon_item.get("SmallImage/URL")
      @item.medium_image = amazon_item.get("MediumImage/URL")
      @item.large_image  = amazon_item.get("LargeImage/URL")
      @item.detail_page_url = amazon_item.get("DetailPageURL")
      @item.raw_info        = amazon_item.get_hash
      @item.save!
    end
      
      
    # TODO ユーザにwant or haveを設定する
    # params[:type]の値ににHaveボタンが押された時にはの時は「Have」,
    # Wantボタンがされた時には「Want」が設定されています。
    
    if params[:item_id]
      @item = Item.find(params[:item_id])
      current_user.have(@item_id)
    end
    
    if  params[:item_id]
      @item = Item.find(params[:item_id])
      current_user.want(@item_id)
    end
    
  end

  def destroy
    @item = Item.find(params[:item_id])
    
   if params[:type] == "Have"
    @item = haves.haved 
    current_user.unhave(@item)
   end
   
   if params[:type] == "Want"
     @item = wants.wanted
    current_user.unwant(@item)
   end  

    # TODO 紐付けの解除。 
    # params[:type]の値ににHavedボタンが押された時にはの時は「Have」,
    # Wantedボタンがされた時には「Want」が設定されています。

  end
end
