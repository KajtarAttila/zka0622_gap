@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Spacefarer Projection'

@UI.headerInfo: {
  typeName: 'Spacefarer',
  typeNamePlural: 'Spacefarers',
  title: { value: 'Name' },
  description: { value: 'OriginPlanet' }
}

define root view entity ZKA0622_ZC_SFARER
  provider contract transactional_query
  as projection on ZKA0622_VI_SFARER
{

    @UI.facet: [
      {
        id: 'General',
        type: #IDENTIFICATION_REFERENCE,
        label: 'Spacefarer Details',
        targetQualifier: 'General',
        position: 10
      }
    ]
    
    key spacefarer_id,
    @EndUserText.label: 'Name'
    @UI.identification: [{ position: 10, qualifier: 'General' }]
    @UI.lineItem: [{ position: 10 }]
    name as Name,
    
    @EndUserText.label: 'Wormhole Navigation Skill'
    @UI.identification: [{ position: 20, qualifier: 'General' }]
    @UI.lineItem: [{ position: 20 }]
    wormhole_skill as WormholeNavigationSkill,
    
    @EndUserText.label: 'Reputation'
    @UI.identification: [{ position: 30, qualifier: 'General' }]
    @UI.lineItem: [{ position: 30 }]
    reputation as Reputation,
    
    @EndUserText.label: 'Origin Planet'
    @UI.identification: [{ position: 40, qualifier: 'General' }]
    @UI.lineItem: [{ position: 40 }]
    origin_planet as OriginPlanet,
    
    @EndUserText.label: 'Spacesuit Color'
    @UI.identification: [{ position: 50, qualifier: 'General' }]
    @UI.lineItem: [{ position: 50 }]
    spacesuit_color as SpacesuitColor,
    
    @EndUserText.label: 'Credits'
    @UI.identification: [{ position: 60, qualifier: 'General' }]
    @UI.lineItem: [{ position: 60 }]
    credits as Credits,
  
  last_changed_at

}
