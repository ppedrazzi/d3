
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
                year: 1976
            chartData.insert
                value: 25
                year: 2000
            chartData.insert
                value: 100
                year: 2010
            chartData.insert
                value: 150
                year: 1981
