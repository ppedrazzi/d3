
chartData = new Mongo.Collection("chartData")

if Meteor.isClient
    Meteor.startup () ->
        Meteor.call("clearChartData")
        Meteor.call("buildChartData")
        console.log "Client is alive."

    Template.barChart.events
        'click #addItem': ->
            Meteor.call("addNewDocument")

    cursor = chartData.find()
    cursor.observeChanges
        added: (id, fields) ->
            console.log "ADDED:", id, fields.value
            data = cursor.fetch()
            bars = d3.select('#barChart')
                .selectAll('rect')
                .data(data)

            bars.enter()
            #enter creates/appends divs for anything selected above that does not exist.
                .append('rect')
                .on("mouseover", (d) ->
                    console.log "id", id, "value:", d.value)
                .on("click", (d) ->
                    chartData.remove({_id: id}) )

            bars.attr
                x: (d, i) ->
                    if i is 0
                        0
                    else
                        70 * i
                y: 0
                width: 50
                height: (d) -> d.value

            bars.style
                fill: '#1FB6ED'

        changed: (id, fields) ->
            console.log "CHANGED:", id, fields.value

        removed: (id) ->
            console.log "REMOVED", id
            data = cursor.fetch()
            bars = d3.select('#barChart')
                .selectAll('rect')
                .data(data)

            #exit captures anything that is missing - then we called style but likely just remove()
            bars.exit().remove()


if Meteor.isServer
    Meteor.startup () ->
        console.log "Server is alive."

    Meteor.methods
        clearChartData: () ->
            chartData.remove({})
        addNewDocument: () ->
            chartData.insert
                value: Random.fraction() * 100

        buildChartData: () ->
            chartData.insert
                value: 50
            chartData.insert
                value: 25
            chartData.insert
                value: 100
            chartData.insert
                value: 150
