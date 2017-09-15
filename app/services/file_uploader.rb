class FileUploader < TransactionManager

  FILE_ERROR = 'Arhivo adjunto inexistente.'

  attr_reader :file, :claim

  def initialize(claim:, params:)
    @claim  = claim
    @params = params
  end

  def call
    return false unless valid_claim? && valid_file? && user

    @file = ClaimFile.new(file_params)
    create_attachment

    if file.save
      @attachment.update(fileable: file)
      file.upload_file
      true
    else
      @error_type = Const::VALIDATION_ERROR
      @errors     = file.errors
    end

  rescue ActiveRecord::RecordNotFound
    @error_type = Const::VALIDATION_ERROR
    @errors     = Const::USER_NOT_FOUND_ERROR
  end

  private

  def valid_claim?
    @claim ||= Claim.find(@params[:claim_id])

    if @claim.deleted_at.nil?
      true
    else
      raise ActiveRecord::RecordNotFound
    end

  rescue ActiveRecord::RecordNotFound
    @error_type = Const::VALIDATION_ERROR
    @errors     = Const::CLAIM_NOT_FOUND_ERROR
    false
  end

  def valid_file?
    if @params[:file].blank?
      @error_type = Const::VALIDATION_ERROR
      @errors     = FILE_ERROR
      false
    else
      true
    end
  end

  def create_attachment
    name, extension = @params[:file].original_filename.split '.'

    @attachment = Attachment.create(
      original_name: name,
      extension:     extension,
      source:        @params[:file]
    )
  end

  def file_params
    @file_params ||= {
      tipo_de_adjunto:  'Anexo',
      etiqueta:         @params[:file].original_filename,
      nombre:           @params[:file].original_filename,
      tramite_id:       @claim.id,
      usuario_id:       user.id,
      id_crm:           @params[:crm_id],
      modulo_de_origen: @params[:source_module]
    }
  end

end
