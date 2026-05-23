#import "@preview/simple-cheatsheet:0.1.0": cheatsheet, container

#show: cheatsheet.with(
  info: (
    title: "XAI",
    authors: ("Stanislas Laurent",),
  ),
)

= MLDM
#container[
  == Gradient descent
  - *Chain rule*: $f(g(x))' = f'(g(x)) dot g'(x)$
    
]

= Intro 
#container[
  == XAI for...
  - *Competence:* improving/debugging models 
  - *Fairness:* detecting/removing unwanted bias 
  - *Safety:* making safe decisions
  - *Usability:* actionable decision making
  - *Human-AI collaboration:* better control and user interaction
  - *Accountability:* enabling documentation and governance
  - *Privacy:* preserving privacy
  - *Legislation:* Anti-discrimination laws, GDPR (General Data Protection Regulations), EU AI Act, California Consumer Privacy Act
    
  == Terms
  - *Explainability*: how well human can understand model's reasoning, decisions & predictions. 
  - *Explanation*: Interface human<>model. Accurate proxy of model, but human-readable.
  - *Interpretability:* how well human can understand internal mechanics of model. 
  - *Transparency:* The openness and visibility into how an AI system operates, including access to its design, data, algorithms, and decision-making processes.

  #image("expl-vs-accu.png")
  #image("table_xai_model.png")
]

= Inherent explainability 
#container[
  == GAMs, GA²Ms, NGAMs

  == Explainable Boosting Machine

  == Interpretable Decision Sets (IDS)
]

= Black-box explainability 
#container[
  == Taxonomy
  #image("blackboxtaxo.png")
  === Stage
  - *In-model:* explainability computed directly during model prediction
  - *Post-hoc:* explainability computed using the model's output

  === Scope
  - *Local:* explain the prediction for a single input sample
  - *Global:* explain the model's average behaviour for all inputs

  === Explnation types
  - *Analytic statement:* natural language descriptions of elements and context important for the model output/decision
  - *Visualisations:* highlight parts of data important for the decision/prediction
  - *Examples:* give illustrative/typical examples that support the prediction
  - *Counterfactuals:* provide the changes needed to get different decisions

  == Local

  === LIME

  LIME is *model agnostic*; it works in the input space (e.g. words for LLMs), not the internal space (embeddings for LLMs).

  We want to explain sample $x$.
  1. Create a synthetic sample set around $x$ by perturbing it.
    - For text: randomly hides (toggles off) words from the original sentence.
    - For images: randomly hides "super-pixels" (segments of the image).
    - For tabular Data: samples from a normal distribution based on the mean and standard deviation of each feature in your training set.
  2. Input those synthetics samples into the black-box model.
  3. Weight the outputs based on the sample's distance to $x$.
  4. Train inherently x. model on the weighted synthetic outputs. (e.g linear reg.)
]


= Mechanistic interpretability
#container[
  - *Goal:* Reverse-engineering $->$ study model internals/model cognition
  - *Hypothesis:* model's underlying principles/structures generalise & learn human understandable algorithms
  == Features vs. Circuits
  - *Features/Concepts: * What the model knows, internal concept learned, e.g. holiday neurons fire for names, decorations etc.
  - *Cicuits/Functions: *Set of internal components/connections that together produce a behaviour: How does the model compute decisions?
  == Transformers
  complex architecture for interrelated sequential data $->$ hard to understand
  === Self-Attention
  - *Query*: What a token asks for; *Key*: what a token can match against; *Value: *Information contributed by token
  $"Attention"(X) = V * "softmax[K[X]^T]"$
  
]