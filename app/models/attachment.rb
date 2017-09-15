class Attachment < ActiveRecord::Base

  # -- Associations
  belongs_to :fileable, polymorphic: true, optional: true

  # -- Misc
  mount_uploader :source, Uploader

  # -- Methods
  def path
    source.file.file
  end

  def filename
    source.file.filename
  end

end
