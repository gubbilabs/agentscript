# algorithm.coffee is a collection of algorithms useful in some agent-based modeling contexts

# A generalized, but complex, flood fill, designed to work on any
# agentset type. To see a simpler version, look at the gridpath model.
#
# Floodfill arguments:
#
# * aset: initial array of agents, often a single agent: [a]
# * fCandidate(a, asetLast) -> true if a is elegible to be added to the set
# * fJoin(a, asetLast) -> adds a to the agentset, usually by setting a variable
# * fCallback(asetLast, asetNext) -> optional function to be called each iteration of floodfill;
# if fCallback returns true, the flood is aborted
# * fNeighbors(a) -> returns the neighbors of this agent
# * asetLast: the array of the last set of agents to join the flood;
# gets passed into fJoin, fCandidate, and fCallback

# old
# ABM.AgentSet.prototype.floodFill = (aset, fCandidate, fJoin, fCallback, fNeighbors, asetLast=[]) ->
#   floodFunc = @floodFillOnce(aset, fCandidate, fJoin, fCallback, fNeighbors, asetLast)
#   floodFunc = floodFunc() while floodFunc

class ABM.FloodFill
  constructor: (@startingSet, @fCandidate, @fJoin, @fNeighbors) ->
    @nextStep = () => @floodFillOnce @startingSet, @fCandidate, @fJoin, @fNeighbors

  floodFillOnce: (aset, fCandidate, fJoin, fNeighbors, asetLast=[]) =>
    fJoin p, asetLast for p in aset
    asetNext = []
    for p in aset
      for n in fNeighbors(p) when fCandidate n, aset
        asetNext.push n if asetNext.indexOf(n) < 0
    
    if asetNext.length is 0
      @nextStep = null
    else
      @nextStep = () => @floodFillOnce asetNext, fCandidate, fJoin, fNeighbors, aset
    
    @prevFront = aset
    @nextFront = asetNext

class ABM.Patches.FloodFill extends ABM.FloodFill
  constructor: (@startingSet, @fCandidate, @fJoin, @fNeighbors = ((patch) -> patch.n)) ->
    super(@startingSet, @fCandidate, @fJoin, @fNeighbors)

ABM.AgentSet.prototype.floodFill = (aset, fCandidate, fJoin, fNeighbors, asetLast=[]) ->
  flood = @floodFillOnce(aset, fCandidate, fJoin, fNeighbors, asetLast)
  flood = flood.nextStep() while flood

# Move one step forward in a floodfill. floodFillOnce() returns a function that performs the next step of the flood.
# This is useful if you want to watch your flood progress as an animation.

# old
# ABM.AgentSet.prototype.floodFillOnce = (aset, fCandidate, fJoin, fCallback, fNeighbors, asetLast=[]) ->
#   fJoin p, asetLast for p in aset
#   asetNext = []
#   for p in aset
#     for n in fNeighbors(p) when fCandidate n, aset
#       asetNext.push n if asetNext.indexOf(n) < 0
#   stopEarly = fCallback and fCallback(aset, asetNext)
#   if stopEarly or asetNext.length is 0 then return null
#   else return () =>
#     @floodFillOnce asetNext, fCandidate, fJoin, fCallback, fNeighbors, aset

ABM.AgentSet.prototype.floodFillOnce = (aset, fCandidate, fJoin, fNeighbors, asetLast=[]) ->
  fJoin p, asetLast for p in aset
  asetNext = []
  for p in aset
    for n in fNeighbors(p) when fCandidate n, aset
      asetNext.push n if asetNext.indexOf(n) < 0
  
  if asetNext.length is 0
    return null
  else
    return {
      nextStep: () => @floodFillOnce asetNext, fCandidate, fJoin, fNeighbors, aset
      prevFront: aset,
      nextFront: asetNext
    }


# The same floodFill algorithm, but with fNeighbors defaulted to return patch neighbors
ABM.Patches.prototype.floodFillOnce = (aset, fCandidate, fJoin, fNeighbors=((p)->p.n), asetLast=[]) ->
  ABM.Patches.__super__.floodFillOnce.call(this, aset, fCandidate, fJoin, fNeighbors, asetLast)