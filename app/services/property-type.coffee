'use strict'

angular.module('oneImobiliaria')
.service 'PropertyTypeService', () ->

  items = [
    {title: 'Apartamento', code: 'apartment'},
    {title: 'Casa', code: 'house'},
    {title: 'Terreno', code: 'land'},
    {title: 'Casa', code: 'house'},
    {title: 'Carro', code: 'car'}
  ]

  getAll: () ->
    return items