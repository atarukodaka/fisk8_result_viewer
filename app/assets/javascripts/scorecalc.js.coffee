class Element
        @BaseValue =
                '4T': 10
        constructor: (name, goe) ->
                @name = name
                @goe = goe
        bv: ->
                Element.BaseValue[@name]
        value: ->
                @bv()

class RuleSet
        @season: ""
        
$ ->
        $('input#calc').click ->
                score_calc()
        
        score_calc = ->
                tes = 0
                elements = []
                num_elements = 13
                for i in [1...num_elements]
                        name = $("#element_#{i}_name").val()
                        goe = $("#element_#{i}_goe").val()
                        elements[i] = new Element(name, goe)
                        element = elements[i]
                        $("#element_#{i}_bv").text(element.bv())
                        $("#element_#{i}_value").text(element.value())
                        $("#element_#{i}_comment").text(name)
                        tes += element.value()
                $('#tes').text(tes)

