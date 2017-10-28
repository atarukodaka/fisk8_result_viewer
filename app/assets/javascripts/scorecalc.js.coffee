class Element
        @rule_set = new RuleSetProject.RuleSet
        
        constructor: (@name, @goe,  @credit) ->
                @type = ""
                @indivisual_jumps = []  # for jump
                @normalized_name = @name
                @goe = parseInt(@goe)
                @invalid = false
                
                @parse()

        round: (value, n) ->
                return Math.round(value * Math.pow(10, 2)) / Math.pow(10, 2)
                
        bv: ->
                value = 0
                if @type is 'jump'
                        _bv= 0
                        for jump in @indivisual_jumps
                                _bv += jump.bv()
                        _bv *= 1.1 if @credit

                else
                        _bv = Element.rule_set.bv(@normalized_name)
                        console.log(_bv)

                @round(_bv, 2)

        goe_value: ->
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
                        #console.log("#{@normalized_name}, #{@goe}")
                        #console.log(Element.rule_set.sov("LSp4", @goe))
                @round(gv, 2)

        value: ->
                @round(@bv() + @goe_value(), 2)
                
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
                @error = false
                @attention = false
                @underrotated = false
                @downgraded = false
                @rotation = 0
                @type = ''
                super(@name, @goe, @credit)

        bv: ->
                name = @normalized_name
                if @downgraded
                        less_rotation = @rotation - 1
                        name = "#{less_rotation}#{@type}"
                        
                v = 0
                v++ if @underrotated
                v++ if @error
                _bv = Element.rule_set.bv(name, v)
                # TODO: downgraded
                return _bv
        parse: ->
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

               
                       
class TechnicalScore
        constructor: ->
                @elements =  []
        add_element: (name, goe, credit) ->
                @elements.push(new Element(name, goe, credit))
        calc: ->
                @tes = 0
                @total_bv = 0
                for element in @elements
                        @tes += element.bv() + element.goe_value()
                        @total_bv += element.bv()
                

this.hello = ->
        console.log("hel")
        
this.score_calc = ->
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


$ ->
        $('input#calc').click ->
                score_calc()

        $('#load_score_form')
                .on "ajax:success", (data, status, xhr) ->
                        console.log(data)
                        console.log(data.detail[0])
