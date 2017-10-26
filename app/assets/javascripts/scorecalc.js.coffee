class RuleSet
        constructor: ->
                @bvsov =
                        '4T': [10, 8, 5, -4, -2.4, -1.2, 0, 1, 2, 3]
                        '3T': [10, 8, 5, -4, -2.4, -1.2, 0, 1, 2, 3]
                        '3A': [10, 8, 5, -4, -2.4, -1.2, 0, 1, 2, 3]
                        '2T':  [10, 8, 5, -4, -2.4, -1.2, 0, 0.7, 1.4, 2.1]
                        'LSp4': [10, 8, 5, -4, -2.4, -1.2, 0, 1, 2, 3]
        bv: (element, v) ->
                v ||= 0
                @bvsov[element][v]
                
        sov: (element, goe) ->
                offset = 6
                # console.log(parseInt(goe)+offset)
                console.log(@bvsov[element][parseInt(goe)+offset])
                @bvsov[element][goe+offset]

class Element
        @rule_set = new RuleSet
        
        constructor: (@name, @goe,  @credit) ->
                @type = ""
                
                # for jump
                @indivisual_jumps = []
                @normalized_name = @name
                @parse()

        bv: ->
                if @type is 'jump'
                        _bv = 0
                        for jump in @indivisual_jumps
                                _bv += jump.bv()
                        return _bv
                else
                        Element.rule_set.bv[@normalized_name]

        goe_value: ->
                if @type is 'jump'
                        max_bv = 0
                        max_element = ''
                        for jump in @indivisual_jumps
                                if jump.bv() > max_bv
                                        max_bv = jump.bv() 
                                        max_element = jump
                        Element.rule_set.sov(max_element.normalized_name, parseInt(@goe))
                else
                        Element.rule_set.sov(@normalized_name, @goe)
                                                

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
                @error = false
                @attention = false
                @underrotated = false
                @downgraded = false
                @name_for_bv = @name
                @rotation = 0
                @type = ''
                super(@name, @goe, @credit)


        bv: ->
                _bv = Element.rule_set.bv(@normalized_name, 0)
                _bv *= 0.7 if @underrotated
                _bv *= 0.5 if @downgraded
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
                if @name.match(/^(.*)e$/)  # wronge edge
                        @error = true
                else if @name.match(/^(.*)\!$/)  # attention
                        @attention = true
                if @name.match(/^([^<]*)(<<?)$/)  # under, downgrade
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

