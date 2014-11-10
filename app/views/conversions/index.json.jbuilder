json.array!(@conversions) do |conversion|
  json.extract! conversion, :id, :convert_me, :credits
  json.url conversion_url(conversion, format: :json)
end
