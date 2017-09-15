class CreateAttachment < ActiveRecord::Migration[5.0]
  def change
    create_table :attachments do |t|
      t.string  :source
      t.integer :fileable_id
      t.string  :fileable_type
      t.string  :original_name
      t.string  :extension
    end
  end
end
