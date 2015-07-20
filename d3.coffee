
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
    cursor.observeChanges
        added: (id, fields) ->
            console.log "ADDED:", id, fields.value
            item = chartData.findOne({_id: id})
            data = []
            data.push(item)
            console.log "new Data:", data
            bar = d3.select('#barChart')
                .selectAll('rect')
                .select('#id-' + id)
                .data(data)

            bar.enter()
            #enter creates/appends divs for anything selected above that does not exist.
                .append('rect')
                .on("mouseover", (d) ->
                    console.log "id:", id, "value:", d.value, "year:", d.year)
                .on("click", (d) ->
                    console.log "clicked remove", id
                    chartData.remove({_id: id}) )

            bar.attr
                x: (d, i) -> d.year * 60
                y: 0
                width: 50
                height: (d) -> d.value
                id: 'id-' + id

            bar.style
                fill: '#1FB6ED'

        changed: (id, fields) ->
            console.log "CHANGED:", id, fields.value
            item = chartData.findOne({_id: id})
            data = []
            data.push(item)
            console.log "Changed Data Element:", data
            bar = d3.select('#id-' + id)
                .data(data)
                .style
                    fill: "red"

            bar.attr
                height: (d) -> d.value

        removed: (id) ->
            console.log "REMOVED", id
            item = chartData.findOne({_id: id})
            data = []
            data.push(item)
            bar = d3.select('#id-' + id)
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
