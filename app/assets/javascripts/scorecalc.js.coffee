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


class Element
        @rule_set = new RuleSet
        
        constructor: (@name, @goe,  @credit) ->
                @type = ""
                
                # for jump
                @indivisual_jumps = []

                @parse()

        bv: ->
                10

        goe_value: ->
                0

        value: ->
                @bv() + @goe_value()
                
        parse: ->
                if @name.match(/Sp/)
                        @type = "spin"
                else if @name.match(/Sq/)
                        @type = "step"
                else
                        @type = "jump"

                 if @type is "jump"
                        for each_name in @name.split('+')
                                @indivisual_jumps.push(new IndivisualJump(each_name, 0, @credit))

class IndivisualJump extends Element
        constructor: (@name, @goe, @credit) ->
                super(@name, @goe, @credit)
                @error = false
                @attention = false
                @underrotated = false
                @downgraded = false
                
        parse: ->
                # check <, <<, !, e
                if @name.match(/(.*)e$/)  # wronge edge
                        @error = true
                else if @name.match(/\!$/)  # attention
                        @attention = true
                if @name.match(/(.*)(<+)$/)  # under, downgrade
                        if RegExp.$2 is '<'
                                @underrotated = true
                        else
                                @downgraded = true

                
                       
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
                        @tes += element.bv() + element.goe_value()
                        @total_bv += element.bv()
                

$ ->
        $('input#calc').click ->
                score_calc()
        
        score_calc = ->
                technical_score = new TechnicalScore

                num_elements = 3
                for i in [1...num_elements]
                        name = $("#element_#{i}_name").val()
                        goe = $("#element_#{i}_goe").val()
                        credit = $("#element_#{i}_credit").prop('checked')
                        if name isnt ""
                                technical_score.add_element(name, goe, credit)
                technical_score.calc()
                i = 1
                for element in technical_score.elements
                        $("#element_#{i}_bv").text(element.bv())
                        $("#element_#{i}_value").text(element.value())
                        $("#element_#{i}_comment").text(element.name)
                        i++
                $('#total_bv').text(technical_score.total_bv)
                $('#tes').text(technical_score.tes)

