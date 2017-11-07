class Element
        @rule_set = new ScorecalcProject.RuleSet
        @round: (value, n) ->
                n ||= 2
                return Math.round(value * Math.pow(10, 2)) / Math.pow(10, 2)
                
        
        constructor: (@name, @goe,  @credit) ->
                @type = ""
                @indivisual_jumps = []  # for jump
                @normalized_name = @name
                @goe = parseInt(@goe)
                @invalid = false
                
                @parse()

        bv: ->
                return 0 if @invalid
                value = 0
                _bv= 0
                if @type is 'jump'
                        for jump in @indivisual_jumps
                                _bv += jump.bv()
                        _bv *= 1.1 if @credit

                else
                        _bv = Element.rule_set.bv(@normalized_name)
                        console.log(_bv)

                Element.round(_bv, 2)

        goe_value: ->
                return 0 if @invalid
                gv = 0
                if @type is 'jump'
                        max_bv = 0
                        max_element = ''
                        for jump in @indivisual_jumps
                                if jump.bv() > max_bv
                                        max_bv = jump.bv() 
                                        max_element = jump
                                        
                        gv = Element.rule_set.sov(max_element.normalized_name, parseInt(@goe))
                else
                        gv = Element.rule_set.sov(@normalized_name, @goe)
                Element.round(gv, 2)

        value: ->
                Element.round(@bv() + @goe_value(), 2)
                
        parse: ->
                if @name.match(/Sp/)
                        @type = "spin"
                else if @name.match(/Sq/)
                        @type = "step"
                else
                        @type = "jump"

                if @type is "jump"
                        if @name.match(/^(.*)\+REP$/)
                                jump = new IndivisualJump(RegExp.$1, 0, @credit)
                                jump.rep = true
                                @indivisual_jumps.push(jump)
                        else
                                for each_name in @name.split('+')
                                        @indivisual_jumps.push(new IndivisualJump(each_name, 0, @credit))

class IndivisualJump extends Element
        constructor: (@name, @goe, @credit) ->
                @error = false
                @attention = false
                @underrotated = false
                @downgraded = false
                @rep = false
                @rotation = 0
                @type = ''
                super(@name, @goe, @credit)

        bv: ->
                return 0 if @invalid
                name = @normalized_name
                if @downgraded
                        less_rotation = @rotation - 1
                        name = "#{less_rotation}#{@type}"
                        
                v = 0
                v++ if @underrotated
                v++ if @error
                if @rep
                        return Element.rule_set.bv(name, v) * 0.7
                else
                        return Element.round(Element.rule_set.bv(name, v), 2)
                               
        parse: ->
                if @name.match(/\*$/)
                        @invalid = true
                if @name.match(/^([1-4])([ASLozFT]+)/)
                        @rotation = parseInt(RegExp.$1)
                        @type = RegExp.$2
                else if @name.match(/^([ASLozFT]+)/)
                        @rotation = 1
                        @type = RegExp.$2
                @normalized_name = "#{@rotation}#{@type}"
                        
                # check <, <<, !, e
                if @name.match(/^(.*)e/)  # wronge edge
                        @error = true
                else if @name.match(/^(.*)\!/)  # attention
                        @attention = true
                if @name.match(/^([^<]*)(<<?)/)  # under, downgrade
                        if RegExp.$2 is '<'
                                @underrotated = true
                        else
                                @downgraded = true

#
class TechnicalScore
        constructor: ->
                @num_elements = 13
                @elements =  []
        add_element: (name, goe, credit) ->
                @elements.push(new Element(name, goe, credit))
        calc: ->
                @tes = 0
                @total_bv = 0
                for element in @elements
                        @tes += element.bv() + element.goe_value()
                        @total_bv += element.bv()
                @tes = Element.round(@tes)
                @total_bv = Element.round(@total_bv)

#================
this.score_calc = ->
        technical_score = new TechnicalScore

        for i in [1..technical_score.num_elements]
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
                i++
        $('#total_bv').text(technical_score.total_bv)
        $('#tes').text(technical_score.tes)

this.reset = ->
        technical_score = new TechnicalScore
        
        for i in [0...technical_score.num_elements]
                $("#element_#{i+1}_name").val('')
                $("#element_#{i+1}_credit").prop('checked', false)
                $("#element_#{i+1}_goe").val(0)
                $("#element_#{i+1}_bv").text('')
                $("#element_#{i+1}_value").text('')
        $('#total_bv').text('')
        $('#tes').text('')

$ ->
        # score_name = purl(location.href).param('score_name')
        if score_name isnt ''
                #console.log(score_name)
                # reset()
                score_calc()
                #console.log("done")

        $('input#calc').click ->
                score_calc()

        $('#reset').click ->
                reset()
