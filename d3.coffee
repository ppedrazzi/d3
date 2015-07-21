
chartData = new Mongo.Collection("chartData")

if Meteor.isClient
    Meteor.startup () ->
        Meteor.call("clearChartData")
        Meteor.call("buildChartData")
        console.log "Client is alive."

    Template.barChart.events
        'click #addItem': ->
            Meteor.call("addNewDocument", (error, result) ->
                if error
                    console.error
                else
                    console.log "Added:", result)

        'click #changeItem': ->
            Meteor.call("changeDocument", (error, result) ->
                if error
                    console.error
                else
                    console.log "Changed:", result)
        'click rect': (event) ->
            #using meteor click event gives you event and template, d3 gives access to data.
            console.log "Meteor click event handler:", event.currentTarget

    Tracker.autorun () ->
        data = chartData.find().fetch()

        svg = d3.select('svg')
            .selectAll('rect')
            .data(data)

        #update operation
        svg.attr
            x: (d, i) -> i * 60
            y: 0
            height: (d, i) ->
                console.log d
                d.value
            width: 50
            fill: "red"
            id: (d, i) -> d._id

        console.log "d3 Selection:", svg

        minYear = d3.min(data, (d) -> d.year)
        maxYear = d3.max(data, (d) -> d.year)
        console.log "max:", maxYear, "min:", minYear
        xScale = d3.scale.linear()
            .domain([minYear, maxYear])
            .range([0, 500])

        #enter operation
        svg.enter()
            .append('rect')
                .attr
                    x: (d, i) -> i * 60
                    y: 0
                    height: (d, i) ->
                        console.log d
                        d.value
                    width: 50
                    fill: "blue"
                    id: (d, i) -> d._id
            .on("mouseover", (d, i) ->
                console.log d)
            .on("click", (d, i) ->
                #using meteor click event gives you event and template, d3 gives access to data.
                console.log "d3 click event handler:", d._id
                Meteor.call("removeDocument", d._id, (error, result) ->
                    if error
                        console.log error
                    else
                        console.log "Removed:", result ))
        #exit operation
        svg.exit().remove()


if Meteor.isServer
    Meteor.startup () ->
        console.log "Server is alive."

    Meteor.methods
        clearChartData: () ->
            chartData.remove({})

        addNewDocument: () ->
            chartData.insert
                value: Random.fraction() * 1000
                year: 1950 + ( Random.fraction() * 1000 )

        removeDocument: (id) ->
            chartData.remove({_id: id})

        changeDocument: () ->
            doc = chartData.findOne()
            chartData.update({_id: doc._id}, {$set: {value: Random.fraction() * 100}} )

        buildChartData: () ->
            chartData.insert
                value: 50
                year: 1980
            chartData.insert
                value: 25
                year: 1975
            chartData.insert
                value: 100
                year: 2010
            chartData.insert
                value: 150
                year: 2000
