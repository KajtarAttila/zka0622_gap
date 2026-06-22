@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Spacefarer Interface'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZKA0622_VI_SFARER 
as select from zka0622_t_sfarer
{
  key spacefarer_id,
  name,
  wormhole_skill,
  reputation,       
  origin_planet,     
  spacesuit_color,   
  credits,
  last_changed_at
   
}
