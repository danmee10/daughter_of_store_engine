require 'spec_helper'

describe 'the user cart view' do
  context 'when there are no items in the cart' do
    it 'displays a message that the cart is empty' do
      store = FactoryGirl.create(:store)
      visit store_home_path(store)
      click_button "Cart"
      page.should have_content "Your cart is empty. Start shopping!"
    end
  end

  context 'when there are items in the cart' do
    before(:each) do
      @store = FactoryGirl.create(:store)
      @product = FactoryGirl.create(:product, store_id: @store.id)
      visit store_product_path(@store, @product)
      click_button 'Add to Cart'
      visit store_cart_path(@store)
    end

    it 'shows the cart with items quantities and prices' do
      expect(page).to have_content('Total')
    end

    context 'the user wants to empty the cart' do
      it 'gets emptied' do
        visit store_product_path(@store, @product)
        click_button 'Add to Cart'
        visit store_cart_path(@store)
        click_link 'Remove'
        expect(page).to have_content('Your cart is empty')
      end
    end

    context 'the user wants to remove an item from the cart' do
      it 'gets removed' do
        click_button 'Empty Cart'
        expect(current_path).to eq "/#{@store.path}"
      end
    end

    context 'the user wants to remove an item from the cart' do
      it 'removes an item' do
        visit store_cart_path(@store)
        fill_in 'carts_quantity', with: '0'
        click_button 'Update'
        expect(find("input#carts_quantity").value).to eq '0'
      end
    end
  end

end
