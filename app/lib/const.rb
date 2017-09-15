class Const

  CLAIM_SOURCE_MODULE_CASES        = 'Cases'
  CLAIM_SOURCE_MODULE_DIGITAL      = 'ATD_atenciones_digitales'
  CLAIM_SOURCE_MODULE_FACE_TO_FACE = 'AtPr_atencion_presencial'
  CLAIM_SOURCE_MODULE_PHONE        = 'Attel_atencion_telefonica'

  # Módulos de origen de trámite
  CLAIM_SOURCE_MODULE = {
    cases:        CLAIM_SOURCE_MODULE_CASES,
    digital:      CLAIM_SOURCE_MODULE_DIGITAL,
    face_to_face: CLAIM_SOURCE_MODULE_FACE_TO_FACE,
    phone:        CLAIM_SOURCE_MODULE_PHONE
  }

  # Errores
  VALIDATION_ERROR          = 'Validación.'
  USER_NOT_FOUND_ERROR      = 'Usuario no encontrado.'
  CLAIM_NOT_FOUND_ERROR     = 'Trámite no encontrado.'
  ATTENTION_NOT_FOUND_ERROR = 'Atención no encontrada.'
  PERSON_NOT_FOUND          = 'Persona no encontrada.'
  THEMATIC_COMB_ERROR       = 'Combinación de temática/subtemática incorrecta.'
  THEMATIC_NOT_FOUND        = 'Temática/subtemática no encontrada.'
  CLAIM_STATE_ERROR         = 'Estado del trámite no válido.'

  # Requerimientos
  CLAIM_INITIAL_STATUS  = 'Requerimiento'
  CLAIM_INITIAL_OBS     = 'Clasificación inicial como REQUERIMIENTO'

  # Quejas
  CLAIM_COMPLAIN_STATUS = 'Queja'
  CLAIM_COMPLAIN_OBS    = 'Clasificacion inicial como QUEJA'

  # Mandrill
  MANDRILL_CONTACT_REQUIRED = 'defensoria-atencion-requerida'
  MANDRILL_CONTACT_REQUIRED_CREATE_TEXT = 'Se ha generado una atención que requiere contacto posterior.'
  MANDRILL_CONTACT_REQUIRED_UPDATE_TEXT = 'Se ha modificado una atención que requiere contacto posterior.'

end
