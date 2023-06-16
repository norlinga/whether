# frozen_string_literal: true

# after search, redirects to forecast#index if nothing found,
# redirects to forecast#choose if there are multiple / ambiguous
# results, or redirects to forecast#show if one result is found
class AddressController < ApplicationController
  def search
    @address_search_result = LocationDataForAddress.call(params[:search_text])
    if @address_search_result.empty?
      redirect_to root_path, alert: t('address.notfound')
    elsif @address_search_result.is_a?(Hash)
      redirect_to forecast_path(@address_search_result[:zip])
    elsif @address_search_result.is_a?(Array)
      flash[:notice] = t('address.ambiguous')
      render template: 'address/choose', layout: 'forecast'
    end
  end

  def choose; end
end
