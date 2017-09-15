class Uploader < CarrierWave::Uploader::Base

  storage :file

  def filename
    return @new_filename if @new_filename

    if original_filename.present?
      time   = Time.now.to_i
      string = (0...5).map { ('a'..'z').to_a[rand(26)] }.join

      @new_filename = "#{time}_#{string}_#{original_filename}"
    end
  end

  def store_dir
    'uploads/claims'
  end

  #def extension_whitelist
    #%w(jpg jpeg png pdf)
  #end

end
