'use strict'

angular.module('oneImobiliaria')
.controller 'UsersCtrl', ['$scope', '$rootScope', '$state', '$stateParams', '$filter', '$loading', '$logger', 'storage','UserGroupService', 'UserService', ($scope, $rootScope, $state, $stateParams, $filter, $loading, $logger, storage, UserGroupService, UserService) ->

  $scope.user = {}
  $scope.users = []

  $scope.groups = UserGroupService.getAll()
  $scope.edit = true

  $loading.show()
  if $stateParams.id
    UserService.get($stateParams.id)
    .then (response) ->
      $scope.user = response.data
      $scope.edit = false
      $loading.hide()
    .catch (response) ->
      $logger.error('Erro ao buscar usuários. Por favor, atualize a página.')
      $loading.hide()
  else
    UserService.getAll()
    .then (response) ->
      $scope.users = $filter('orderBy')(response.data, '-created')
      $loading.hide()
    .catch (response) ->
      $logger.error('Erro ao buscar usuários. Por favor, atualize a página.')
      $loading.hide()

  $scope.canEdit = () ->
    $scope.edit = true

  $scope.saveOrUpdate = () ->
    if !$rootScope.forms.user.$valid
      $logger.error('Preencha todos os dados obrigatórios.')
      return

    $loading.show()
    UserService.saveOrUpdate($scope.user)
    .then (response) ->
      $loading.hide()
      $state.go('dashboard.users')
    .catch (response) ->
      $logger.error('Erro ao criar/editar usuário. Por favor, tente novamente.')
      $loading.hide()

  $scope.doDelete = (index) ->

    user = $scope.users[index]
    return false if user._id == storage.getCode()

    $loading.show()
    UserService.delete(user._id)
    .then (response) ->
      $logger.success('Usuário deletado com sucesso!')
      $scope.users.splice(index, 1)
      $loading.hide()
    .catch (response) ->
      $logger.error('Erro ao deletar usuário. Por favor, tente novamente.')
      $loading.hide()

]