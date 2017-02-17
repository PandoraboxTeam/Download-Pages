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

    gulp.task 'build', ['html', 'scripts', 'css','generate']

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

    gulp.task 'css', ->

        gulp.src 'src/*.css'
            .pipe $.csso()
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
        gulp.watch 'src/*.css', ['css']

    glob = require 'glob'
    Promise  = require 'bluebird'
    gulp.task 'generate', ->

        files = glob.sync 'data/tree.file'
        return if files.length is 0

        data = [ ]

        pushItem2Last = (arr=[ ], item={ }, depth=0) ->
            if depth is 0
                arr.push item
                return arr
            arr[arr.length - 1].list ?= [ ]
            _arr = arr[arr.length - 1].list

            arr[arr.length - 1].list = pushItem2Last(_arr, item, depth - 1)
            return arr

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
                    else
                        obj = { name: fileMatch[2] }
                        pushItem2Last(data, obj, (matches[0].length / 4) - 1)
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
