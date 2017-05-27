'use strict'

angular.module('oneImobiliaria')
.controller 'ConfirmCtrl', ['$scope', '$rootScope', '$q', '$state', '$filter', '$loading', '$logger', 'storage', 'PropertyService', 'LocationService', 'ClientService', ($scope, $rootScope, $q, $state, $stateParams, $filter, $loading, $logger, storage, PropertyService, LocationService, ClientService) ->

  $scope.properties = []
  $scope.cities = []
  $scope.states = []
  $scope.clients = []
  $scope.search = {}
  cities = []

  $scope.edit = true

  $loading.show()
  LocationService.getAllStates()
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

  $scope.doEditCsv = (index) ->
    item = $scope.newProperties.errors[index]
    $scope.property = item.property
    $scope.property.client = item.client._id
    $scope.property.address.cep = $scope.property.address.cep.replace(/[^0-9.]/g, "") if $scope.property.address?.cep?
    delete $scope.property._id
    $rootScope.toggleModal()

  $scope.doTryAgain = (index) ->
    item = $scope.newProperties.errors[index]
    property = item.property
    property.client = item.client._id
    delete property._id

    $scope.property = property

    saveOrUpdate()
    .then () ->
      $scope.newProperties.errors.splice(index, 1)

  $scope.saveOrUpdateModal = (index) ->
    if !$rootScope.forms.property.$valid
      $logger.error('Preencha todos os dados obrigatórios.')
      return

    saveOrUpdate()
    .then () ->
      $scope.newProperties.errors.splice(index, 1)
      $rootScope.toggleModal()

  $scope.doRemoveCsv = (index) ->
    $scope.newProperties.errors.splice(index, 1)

  saveOrUpdate = () ->
    if not $scope.property?
      return false

    promise = $q.defer()
    $loading.show()

    revertData()
    PropertyService.saveOrUpdate($scope.property)
      .then (response) ->
        $loading.hide()
        promise.resolve()
      .catch (response) ->
        promise.reject()
        if response.data.code == 8
          $logger.error('Verifique o endereço digitado. Não foi possível validar esta informação.')
        else
          $logger.error('Erro ao criar/editar imóvel. Por favor, tente novamente.')
        $loading.hide()

  convertData = () ->
    $scope.property.interest.allMeters =  [10, 500]
    $scope.property.interest.allVacancies = [0, 50]
    $scope.property.interest.allFloors = [1, 30]
    $scope.property.interest.allValues = [1000, 5000000]
    $scope.property.interest.allIptus = [1000, 15000]
    $scope.property.interest.allCondominiums = [1000, 500000]
    $scope.property.interest.allLocations = [1000, 50000]

#    if $scope.property.interest?.types?
#      $scope.property.interest.types = []

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

    if $scope.property.interest?.value?
      $scope.property.interest.allValues[0] = $scope.property.interest.value.min
      $scope.property.interest.allValues[1] = $scope.property.interest.value.max

    if $scope.property.interest?.iptu?
      $scope.property.interest.allIptus[0] = $scope.property.interest.iptu.min
      $scope.property.interest.allIptus[1] = $scope.property.interest.iptu.max

    if $scope.property.interest?.location?
      $scope.property.interest.allLocations[0] = $scope.property.interest.location.min
      $scope.property.interest.allLocations[1] = $scope.property.interest.location.max


  revertData = () ->
    $scope.property.value = $scope.property.value.toFixed(2)
    $scope.property.condominium = $scope.property.condominium.toFixed(2)
    $scope.property.location = $scope.property.location.toFixed(2)
    $scope.property.iptu = $scope.property.iptu.toFixed(2)

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

    if $scope.property.interest.allValues?
      $scope.property.interest.value =
        min: $scope.property.interest.allValues[0]
        max: $scope.property.interest.allValues[1]
      delete $scope.property.interest.allValues

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