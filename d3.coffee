
chartData = new Mongo.Collection("chartData")

if Meteor.isClient
    Meteor.startup () ->
        Meteor.call("clearChartData")
        Meteor.call("buildChartData")
        console.log "Client is alive."

    Template.barChart.events
        'click #addItem': ->
            Meteor.call("addNewDocument")

        'click #changeItem': ->
            Meteor.call("changeDocument")

    cursor = chartData.find()
    cursor.observe
        added: (document) ->
            console.log "ADDED:", document
            data = [document]
            bar = d3.select('#barChart')
                .selectAll('rect')
                .select('#id-' + document._id)
                .data(data)

            bar.enter()
            #enter creates/appends divs for anything selected above that does not exist.
                .append('rect')
                .on("mouseover", (d) ->
                    console.log "id:", d._id, "value:", d.value, "year:", d.year)
                .on("click", (d) ->
                    console.log "clicked remove", d._id
                    chartData.remove({_id: d._id}) )

            bar.attr
                x: (d, i) -> d.year * 60
                y: 0
                width: 50
                height: (d) -> d.value
                id: 'id-' + document._id

            bar.style
                fill: '#1FB6ED'

        changed: (document) ->
            console.log "CHANGED:", document
            data = [document]
            bar = d3.select('#id-' + document._id)
                .data(data)
                .style
                    fill: "red"

            bar.attr
                height: (d) -> d.value

        removed: (document) ->
            console.log "REMOVED:", document
            data = [document]
            bar = d3.select('#id-' + document._id)
                .data(data)

            #exit captures anything that is missing - then we called style but likely just remove()
            bar.remove()


if Meteor.isServer
    Meteor.startup () ->
        console.log "Server is alive."

    Meteor.methods
        clearChartData: () ->
            chartData.remove({})
        addNewDocument: () ->
            chartData.insert
                value: Random.fraction() * 100
                year: 5

        changeDocument: () ->
            doc = chartData.findOne()
            chartData.update({_id: doc._id}, {$set: {value: 500}} )

        buildChartData: () ->
            chartData.insert
                value: 50
                year: 1
            chartData.insert
                value: 25
                year: 2
            chartData.insert
                value: 100
                year: 3
            chartData.insert
                value: 150
                year: 4
