'use strict'

angular.module('oneImobiliaria')
.controller 'PropertiesCtrl', ['$scope', '$rootScope', '$q', '$state', '$stateParams', '$filter', '$loading', '$logger', 'storage', 'PropertyService', 'LocationService', 'ClientService', ($scope, $rootScope, $q, $state, $stateParams, $filter, $loading, $logger, storage, PropertyService, LocationService, ClientService) ->

  $scope.properties = []
  $scope.property = {}
  $scope.cities = []
  $scope.states = []
  $scope.clients = []
  $scope.search = {}
  cities = []

  $scope.edit = true
  $scope.showFilters = false

  $loading.show()
  if $stateParams.id
    PropertyService.get($stateParams.id)
    .then (response) ->
      $scope.property = response.data
      convertData()
      return LocationService.getAllStates()
    .then (response) ->
      $scope.states = response.data.sort()
      return LocationService.getCitiesByState($scope.property.address.state)
    .then (response) ->
      currentCities = $filter('orderByString')(response.data, 'name')
      $scope.cities = currentCities
      cities[$scope.property.address.state] = currentCities
      return ClientService.getAll()
    .then (response) ->
      $scope.clients = $filter('orderByString')(response.data, 'name')
      $scope.edit = false
      $loading.hide()
    .catch (response) ->
      $logger.error('Erro ao buscar imóveis. Por favor, atualize a página.')
      $loading.hide()
  else
    PropertyService.getAll()
    .then (response) ->
      $scope.properties = $filter('orderBy')(response.data, '-created')
      convertData()
      return LocationService.getAllStates()
    .then (response) ->
      $scope.states = response.data.sort()
      return ClientService.getAll()
    .then (response) ->
      $scope.clients = $filter('orderByString')(response.data, 'name')
      $loading.hide()
    .catch (response) ->
      $logger.error('Erro ao buscar imóveis. Por favor, atualize a página.')
      $loading.hide()

  $scope.showCities = (state) ->
    if cities[state]?
      $scope.cities = cities[state]
      return false

    $loading.show()
    LocationService.getCitiesByState(state)
    .then (response) ->
      currentCities = $filter('orderByString')(response.data, 'name')
      $scope.cities = currentCities
      cities[state] = currentCities
      $loading.hide()
    .catch () ->
      $loading.hide()

  $scope.canEdit = () ->
    $scope.edit = true

  $scope.toggleFilters = () ->
    $scope.showFilters = !$scope.showFilters

  $scope.saveOrUpdate = () ->

    if !$rootScope.forms.property.$valid or not $scope.property?
      $logger.error('Preencha todos os dados obrigatórios.')
      return

    $loading.show()
    revertData()
    PropertyService.saveOrUpdate($scope.property)
    .then (response) ->
      $loading.hide()
      $state.go('dashboard.properties')
    .catch (error) ->
      console.log(error);
      if error.data? && error.data.code == 8
        $logger.error('Verifique o endereço digitado. Não foi possível validar esta informação.')
      else
        $logger.error('Erro ao criar/editar imóvel. Por favor, tente novamente.')
      $loading.hide()


  $scope.doDelete = (index) ->
    property = $scope.properties[index]
    return false if property._id == storage.getCode()

    $loading.show()
    PropertyService.delete(property._id)
    .then (response) ->
      $logger.success('Imóvel excluído com sucesso!')
      $scope.properties.splice(index, 1)
      $loading.hide()
    .catch (response) ->
      $logger.error('Erro ao excluir imóvel. Por favor, tente novamente.')
      $loading.hide()

  $scope.doUploadCSV = (file) ->
    if not file? or file.type != 'text/csv'
      $logger.error('Por favor, selecione um arquivo válido do tipo .csv')
      return false

    $rootScope.newProperties = {}

    $loading.show()
    PropertyService.importCsv(file)
    .then (response) ->
      $scope.file = null
      $rootScope.newProperties = response.data.content
      $state.go('dashboard.confirm')
      $loading.hide()
    .catch (response) ->
      $scope.file = {}
      $logger.error('Erro ao importar dados. Por favor, tente novamente.')
      $loading.hide()

  convertData = () ->
    $scope.property.interest = {} if not $scope.property.interest?
    $scope.property.interest.allMeters =  [10, 500]
    $scope.property.interest.allVacancies = [0, 50]
    $scope.property.interest.allFloors = [1, 30]
    $scope.property.interest.allIptus = [1000.00, 15000.00]
    $scope.property.interest.allCondominiums = [1000.00, 500000.00]
    $scope.property.interest.allLocations = [1000.00, 50000.00]

    if $scope.property.interest?.meters?
      $scope.property.interest.allMeters[0] = $scope.property.interest.meters.min
      $scope.property.interest.allMeters[1] = $scope.property.interest.meters.max

    if $scope.property.interest?.condominium?
      $scope.property.interest.allCondominiums[0] = $scope.property.interest.condominium.min
      $scope.property.interest.allCondominiums[1] = $scope.property.interest.condominium.max

    if $scope.property.interest?.vacancy?
      $scope.property.interest.allVacancies[0] = $scope.property.interest.vacancy.min
      $scope.property.interest.allVacancies[1] = $scope.property.interest.vacancy.max

    if $scope.property.interest?.floor?
      $scope.property.interest.allFloors[0] = $scope.property.interest.floor.min
      $scope.property.interest.allFloors[1] = $scope.property.interest.floor.max

    if $scope.property.interest?.iptu?
      $scope.property.interest.allIptus[0] = $scope.property.interest.iptu.min
      $scope.property.interest.allIptus[1] = $scope.property.interest.iptu.max

    if $scope.property.interest?.location?
      $scope.property.interest.allLocations[0] = $scope.property.interest.location.min
      $scope.property.interest.allLocations[1] = $scope.property.interest.location.max


  revertData = () ->
    $scope.property.value = $scope.property.value.toFixed(2)
    $scope.property.condominium = $scope.property.condominium.toFixed(2) if $scope.property.condominium?
    $scope.property.location = $scope.property.location.toFixed(2) if $scope.property.location?
    $scope.property.iptu = $scope.property.iptu.toFixed(2) if $scope.property.iptu?

    return false if not $scope.property.interest?

    $scope.property.interest.types = $filter('objToArray')($scope.property.interest.types, 4)
    $scope.property.interest.payments = $filter('objToArray')($scope.property.interest.payments, 3)

    if $scope.property.interest.allMeters?
      $scope.property.interest.meters =
        min: $scope.property.interest.allMeters[0]
        max: $scope.property.interest.allMeters[1]
      delete $scope.property.interest.allMeters

    if $scope.property.interest.allCondominiums?
      $scope.property.interest.condominium =
        min: $scope.property.interest.allCondominiums[0]
        max: $scope.property.interest.allCondominiums[1]
      delete $scope.property.interest.allCondominiums

    if $scope.property.interest.allVacancies?
      $scope.property.interest.vacancy =
        min: $scope.property.interest.allVacancies[0]
        max: $scope.property.interest.allVacancies[1]
      delete $scope.property.interest.allVacancies

    if $scope.property.interest.allFloors?
      $scope.property.interest.floor =
        min: $scope.property.interest.allFloors[0]
        max: $scope.property.interest.allFloors[1]
      delete $scope.property.interest.allFloors

    if $scope.property.interest.allIptus?
      $scope.property.interest.iptu =
        min: $scope.property.interest.allIptus[0]
        max: $scope.property.interest.allIptus[1]
      delete $scope.property.interest.allIptus

    if $scope.property.interest.allLocations?
      $scope.property.interest.location =
        min: $scope.property.interest.allLocations[0]
        max: $scope.property.interest.allLocations[1]
      delete $scope.property.interest.allLocations
]
