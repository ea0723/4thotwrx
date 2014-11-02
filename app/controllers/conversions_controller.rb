class ConversionsController < ApplicationController
  def home
    
    @conversions = Conversion.new(conversion_params)

  end
  
  def help
  end

  def conversion_params
      binding.pry 
      params.require(:conversion[:convert_me]).permit(:convert_me, :credits)
  end

end
