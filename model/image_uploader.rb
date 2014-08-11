class ImageUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir 
    "images/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}" 
  end
end
