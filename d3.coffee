
Data = new Mongo.Collection("Data")

if Meteor.isClient
    Meteor.startup () ->
        Meteor.call("clearAllData")
        Meteor.call("getData", "http://www.reddit.com/r/pics.json", (error, result) ->
            if error
                console.log error
            else
                console.log result.data.data.children
                Meteor.call("loadData", result.data.data.children) )
        console.log "Client is alive."

    Template.barChart.events
        'click .item': (event, template) ->
            d3.select(event.currentTarget)
                .style
                    'background-color': 'blue'
            console.log "clicked", event.currentTarget

    Template.barChart.onRendered () ->
        data = [50, 100, 150, 200]
        divs = d3.select('#barChart')
            .selectAll('div.item')
            .data(data)

        divs.enter()
        #enter creates/appends divs for anything selected above that does not exist.
            .append('div')
            .classed('item', true)

        divs.style
            width: '40px'
            height: (d, i) -> console.log d;  d + 'px'
            margin: '15px'
            float: 'left'
            'background-color': '#1FB6ED'

        #data has changed...
        data = [22, 200]
        divs = d3.select('#barChart')
            .selectAll('div.item')
            .data(data)

        divs.transition().delay(50).duration(1000)
            .style
                height: (d) -> d + 'px'
                'background-color': 'green'

        #exit captures anything that is missing - then we called style but likely just remove()
        divs.exit().style('background-color': 'red')

###
        svg = d3.select('#barChart')
        object = {
            cx: 150,
            cy: 150,
            r: 50,
            fill: '#1FB6ED'}

        svg.append('circle').attr(object)


        Deps.autorun () ->
            key = (d) ->
                d._id
            dataset = Data.find().fetch()
            bars = svg.selectAll("rect").data(dataset, key)
            bars.enter().append('rect')
            console.log dataset
###

if Meteor.isServer
    Meteor.startup () ->
        console.log "Server is alive."

    Meteor.methods
        clearAllData: () ->
            Data.remove({})

        getData: (url) ->
            HTTP.call("GET", url)

        loadData: (data) ->
            for object in data
                Data.insert
                    name: object.data.name
                    score: object.data.score
                    ups: object.data.ups
                console.log "Inserted:", object.data.name
