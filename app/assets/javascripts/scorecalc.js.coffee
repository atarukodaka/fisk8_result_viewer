class Element
        constructor: (@name, @goe,  @credit) ->
                bv = 0
                value = 0

class RuleSet
        constructor: ->
                @bv =
                        '4T': 10
                        '3T': 8
                @v =
                        '4T': [8]
                        '3T': [6]
                        
                @sov =
                        '4T': [-4, -2.4, -1.2, 0, 1, 2, 3]
                        '3T': [-3, -2, -1, 0, 1, 2, 3]
                       
class TechnicalScore
        constructor: ->
                @elements =  []
                @rule_set = new RuleSet
        add_element: (name, goe, credit) ->
                @elements.push(new Element(name, goe, credit))
        calc: ->
                @tes = 0
                @total_bv = 0
                for element in @elements
                        element.bv = @rule_set.bv[element.name]
                        goe = parseInt(element.goe)
                        goe_value = @rule_set.sov[element.name][goe+3]
                        element.value = element.bv + goe_value
                        @tes += element.value
                        @total_bv += element.bv
                

$ ->
        $('input#calc').click ->
                score_calc()
        
        score_calc = ->
                technical_score = new TechnicalScore

                num_elements = 13
                for i in [1...num_elements]
                        name = $("#element_#{i}_name").val()
                        goe = $("#element_#{i}_goe").val()
                        credit = $("#element_#{i}_credit").prop('checked')
                        if name isnt ""
                                technical_score.add_element(name, goe, credit)
                technical_score.calc()
                i = 1
                for element in technical_score.elements
                        $("#element_#{i}_bv").text(element.bv)
                        $("#element_#{i}_value").text(element.value)
                        $("#element_#{i}_comment").text(element.name)
                        i++
                $('#total_bv').text(technical_score.total_bv)
                $('#tes').text(technical_score.tes)

