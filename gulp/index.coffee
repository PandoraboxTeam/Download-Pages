'use strict'

module.exports = ->

    gulp   = require('gulp')
    $      = require('gulp-load-plugins')({ lazy: true })
    args   = require('yargs').argv
    config = { }

    browserSync = require('browser-sync').create()

    # taskList = require('fs').readdirSync('./gulp/tasks/')
    # taskList.forEach (file) ->
    #     require('./tasks/' + file)(gulp, config, $, args)

    gulp.task 'default', ['build']

    gulp.task 'build', ['html', 'scripts', 'generate']

    gulp.task 'html', ->

        gulp.src 'src/*.jade'
            .pipe $.jade()
            .pipe gulp.dest 'dist/'
            .once 'end', browserSync.reload

    gulp.task 'scripts', ->

        gulp.src 'src/*.coffee'
            .pipe $.coffee()
            .pipe gulp.dest 'dist/'
            .once 'end', browserSync.reload

    gulp.task 'serve', ['build'], ->

        browserSync.init {
            port: 8080
            open: false
            server: 'dist/'
        }

        gulp.watch 'src/*.jade', ['html']
        gulp.watch 'src/*.coffee', ['scripts']

    glob = require 'glob'
    Promise  = require 'bluebird'
    gulp.task 'generate', ->

        files = glob.sync 'data/tree.file'
        return if files.length is 0

        data = [ ]
        (new Promise (resolve) ->

            fs       = require 'fs'
            readline = require 'readline'
            rStream = fs.createReadStream files[0]
            rLine = readline.createInterface {
                input: rStream
            }

            rLine.on 'close', ->
                rLine.close()
                rStream.close()
                # console.log JSON.stringify data
                return resolve()

            rLine.on 'line', (input) ->
                matches = input.match(/^(\W+)/)
                return if !matches

                fileMatch = input.match(/^(\W+)\b(.*)/)
                # TODO 修改重复的
                switch matches[0].length
                    when 1 then return
                    when 4
                        data.push {
                            name : fileMatch[2]
                        }
                    when 8
                        k0 = data.length - 1
                        data[k0].list ?= [ ]
                        data[k0].list.push {
                            name : fileMatch[2]
                        }
                    when 12
                        k0 = data.length - 1
                        k1 = data[k0].list.length - 1
                        data[k0].list[k1].list ?= [ ]
                        data[k0].list[k1].list.push {
                            name : fileMatch[2]
                        }
                    when 16
                        k0 = data.length - 1
                        k1 = data[k0].list.length - 1
                        k2 = data[k0].list[k1].list.length - 1
                        data[k0].list[k1].list[k2].list ?= [ ]
                        data[k0].list[k1].list[k2].list.push {
                            name : fileMatch[2]
                        }
                    when 20
                        k0 = data.length - 1
                        k1 = data[k0].list.length - 1
                        k2 = data[k0].list[k1].list.length - 1
                        k3 = data[k0].list[k1].list[k2].list.length - 1
                        data[k0].list[k1].list[k2].list[k3].list ?= [ ]
                        data[k0].list[k1].list[k2].list[k3].list.push {
                            name : fileMatch[2]
                        }
                    when 24
                        k0 = data.length - 1
                        k1 = data[k0].list.length - 1
                        k2 = data[k0].list[k1].list.length - 1
                        k3 = data[k0].list[k1].list[k2].list.length - 1
                        k4 = data[k0].list[k1].list[k2].list[k3].list.length - 1
                        data[k0].list[k1].list[k2].list[k3].list[k4].list ?= [ ]
                        data[k0].list[k1].list[k2].list[k3].list[k4].list.push {
                            name : fileMatch[2]
                        }
                    when 28
                        k0 = data.length - 1
                        k1 = data[k0].list.length - 1
                        k2 = data[k0].list[k1].list.length - 1
                        k3 = data[k0].list[k1].list[k2].list.length - 1
                        k4 = data[k0].list[k1].list[k2].list[k3].list.length - 1
                        k5 = data[k0].list[k1].list[k2].list[k3].list[k4].list.length - 1
                        data[k0].list[k1].list[k2].list[k3].list[k4].list[k5].list ?= [ ]
                        data[k0].list[k1].list[k2].list[k3].list[k4].list[k5].list.push {
                            name : fileMatch[2]
                        }
                    when 32
                        k0 = data.length - 1
                        k1 = data[k0].list.length - 1
                        k2 = data[k0].list[k1].list.length - 1
                        k3 = data[k0].list[k1].list[k2].list.length - 1
                        k4 = data[k0].list[k1].list[k2].list[k3].list.length - 1
                        k5 = data[k0].list[k1].list[k2].list[k3].list[k4].list.length - 1
                        k6 = data[k0].list[k1].list[k2].list[k3].list[k4].list[k5].list.length - 1
                        data[k0].list[k1].list[k2].list[k3].list[k4].list[k5].list[k6].list ?= [ ]
                        data[k0].list[k1].list[k2].list[k3].list[k4].list[k5].list[k6].list.push {
                            name : fileMatch[2]
                        }
        ).then ->
            lowdb = require 'lowdb'
            dataRaw = data
            # 一级
            data = for item in dataRaw
                obj = {
                    name: item.name
                }
                obj.list = 'online' if item.list?
                obj
            lowdb("dist/data.json").setState(data)

            # 二级
            for item in dataRaw when item.list?
                data = for v1 in item.list
                    obj = {
                        name: v1.name
                    }
                    obj.list = 'online' if v1.list?
                    obj
                lowdb("dist/data-#{item.name}.json").setState(data)

            # 三级
            for item in dataRaw when item.list?
                for v1 in item.list when v1.list?
                    data = for v2 in v1.list
                        obj = {
                            name: v2.name
                        }
                        obj.list = 'online' if v2.list?
                        obj
                    lowdb("dist/data-#{item.name}-#{v1.name}.json").setState(data)

            # 四级
            for item in dataRaw when item.list?
                for v1 in item.list when v1.list?
                    for v2 in v1.list when v2.list?
                        data = for v3 in v2.list
                            obj = {
                                name: v3.name
                            }
                            obj.list = 'online' if v3.list?
                            obj
                        lowdb("dist/data-#{item.name}-#{v1.name}-#{v2.name}.json").setState(data)

            # 五级
            for item in dataRaw when item.list?
                for v1 in item.list when v1.list?
                    for v2 in v1.list when v2.list?
                        for v3 in v2.list when v3.list?
                            data = v3.list
                            lowdb("dist/data-#{item.name}-#{v1.name}-#{v2.name}-#{v3.name}.json").setState(data)


    return
