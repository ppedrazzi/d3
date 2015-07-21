
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

    Tracker.autorun () ->
        data = chartData.find().fetch()
        svg = d3.select('svg')
            .selectAll('circle')
            .data(data)
        console.log "Selected", svg

        maxYear = d3.max(data, (d) -> d.year)
        console.log "max is", maxYear
        xScale = d3.scale.linear()
            .domain([0, maxYear])
            .range([0, 500])

        svg.enter()
            .append('circle')
                .attr
                    cx: (d, i) -> xScale(d.year)
                    cy: 100
                    r: (d, i) -> d.value
                    fill: "blue"



if Meteor.isServer
    Meteor.startup () ->
        console.log "Server is alive."

    Meteor.methods
        clearChartData: () ->
            chartData.remove({})

        addNewDocument: () ->
            chartData.insert
                value: Random.fraction() * 100
                year: 1950 + ( Random.fraction() * 100 )

        changeDocument: () ->
            doc = chartData.findOne()
            chartData.update({_id: doc._id}, {$set: {value: Random.fraction() * 100}} )

        buildChartData: () ->
            chartData.insert
                value: 50
                year: 1000
            chartData.insert
                value: 25
                year: 555
            chartData.insert
                value: 100
                year: 3000
            chartData.insert
                value: 150
                year: 5000
