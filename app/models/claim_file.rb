class ClaimFile < SymfonyDatabase

  self.table_name = :archivo_de_tramite

  # -- Associations
  has_one :attachment, as: :fileable

  # -- Methods
  def upload_file
    update(nombre: self.attachment.filename)

    Net::SFTP.start(
      ENV['SCP_HOST'],
      ENV['SCP_USERNAME'],
      password: ENV['SCP_PASSWORD']
    ) do |sftp|

      begin
        sftp.mkdir!(
          "#{ENV['SCP_TARGET']}#{self.tramite_id}",
          permissions: 0777
        )
      rescue Net::SFTP::StatusException => e
        # Directorio ya existente
      end

      sftp.upload!(
        self.attachment.path,
        "#{ENV['SCP_TARGET']}#{self.tramite_id}/#{self.attachment.filename}"
      )
    end
  end

end
