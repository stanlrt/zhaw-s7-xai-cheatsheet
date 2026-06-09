#import "@preview/simple-cheatsheet:0.1.0": cheatsheet, container

#show: cheatsheet.with(
  info: (
    title: "XAI",
    authors: ("Stanislas Laurent",),
  ),
)

= ML Recap & Evaluation
#container[
  - *Chain rule*: $f(g(x))' = f'(g(x)) dot g'(x)$
  
  == Loss Functions & Model Selection
  - *Regression:* Evaluated using Mean Squared Error (MSE).
  - *Classification:* Last layer uses Softmax activation. Evaluated using log loss (CCE): $L = - 1 / N sum_(i=1)^N [ y_i log(p_i) + (1 - y_i) log(1 - p_i) ]$.
  - *Error Decomposition:* $"MSE" = "systematic error" ("bias"^2) + "dependence on sample" ("variance") + "irreducible error" ("noise")$.
  - *Bias-Variance Tradeoff:* Complex models generally decrease bias but increase variance. 
  - *Overfitting* occurs when training error is low but test error increases.
  - *Nested Cross Validation:* Used for limited data. The inner loop handles model selection (hyperparameter tuning), and the outer loop estimates generalization performance.

  == Performance Measures
  - *Confusion Matrix:* True Positive (TP), True Negative (TN), False Positive (FP), False Negative (FN).
  - *Precision:* $"TP" / ("TP" + "FP")$ - How many detected samples are actually relevant.
  - *Recall/Sensitivity:* $"TP" / ("TP" + "FN")$ - How many relevant samples are correctly detected.
  - *F1 Score:* $2 dot ("Precision" dot "Recall") / ("Precision" + "Recall")$.
  - *Multiclass Aggregation:*
    - *Macro:* Averages the metric across all classes equally ($1/C sum "Metric"_c$). Treats all classes equally.
    - *Micro:* Sums all TPs, FPs, and FNs globally before calculating the metric. Favors frequent/majority classes.
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
  - *Interpretability:* how well human can understand internal mechanics of model. 
  - *Explanation*: Interface human<>model. Accurate proxy of model, but human-readable.
  - *Transparency:* The openness and visibility into how an AI system operates, including access to its design, data, algorithms, and decision-making processes.

  #stack(dir: ltr,
    image("expl-vs-accu.png", width: 40%),
    image("table_xai_model.png", width: 60%),
  )
]

= Inherent explainability 
#container[
   == GAMs, GA²Ms, NGAMs
  - *GAMs*: $g(y) = beta_0 + sum f_j(x_j)$
  - *GA²Ms:* Extend GAMs to model second-order feature interactions: $g(y) = beta_0 + sum f_j(x_j) + sum_{i != j} f_{i,j}(x_i, x_j)$. Fits a GAM first, then ranks all possible interaction pairs in the residual, selecting the top pairs. Note: Additive terms show modular contributions but capture associations/correlations, not causality.
  - *NGAMs:* Uses neural networks as shape functions instead of traditional splines. Each feature is processed separately by a neural network, and outputs of all networks are added to produce the final output.
  - *XAI*: each spline function can be considered individually. But: Captures associations/correlations not causality! 

  == Explainable Boosting Machine
  - A tree-based gradient boosting GA²M.
  - Learns the shape function of each feature in a *round-robin fashion* (one feature at a time) using gradient boosting with very small learning rates so feature order does not matter.
  - Automatically detects and includes pairwise feature interactions.
  - Two-stage training: Builds single-feature models first, then builds pairwise interactions on the residuals.
  - Slow training, but fast inference.

  == Interpretable Decision Sets (IDS)
  - Learns a collection of simple, non-overlapping *if-then rules*. 
  - *Two-step approach:* 1) Apply frequent itemset mining (Apriori algorithm) to obtain candidate itemsets. 2) Apply a smooth local search approach to optimize the rules until convergence.
  - *Optimization Objectives:*
    - *Performance:* Optimize Precision (minimize incorrect covers) and Recall (encourage correct covers).
    - *Interpretability:* Optimize for Parsimony (fewer rules/conditions), Distinctness (minimal intra-class and inter-class overlap to prevent contradicting explanations), and Class Coverage (ensure all classes are explained, not just the majority).
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

= Post-Hoc concept based methods
#container[
  
]

= In-model explainability approaches
#container[

  
]

= Neurosymbolic approaches
#container[

  
]

= Evaluating explanations
#container[
  No single established way to eval. model explanations: highly dependant on type of model explanation, task, domain

  *why?: *most pick explanations match their intuition, or are most familiar
  == Different aspects
  - *Correctness of explanations*: How accurate/precise are they?
  - *Relevance: * Meaningfulness of explanations
  - *Interpretability:* how interpretable are they?
  - *Actionability: * can they help improve the model?
  - *Succinctness: * how concise/compact are they?
  - *Completeness*
  - * Robustness/stability*
  *Common metrics:* pred. performance improvement, decision time, user satisfaction, expert agreement, complexity, stability scores
  == Evaluation types
  === Application-grounded (most specific, realistic, costly)
  - *Domain experts* do XAI help doctors make better diagnosis?
  - *Metrics*: diagnostic accuracy, decision time, trust...
  === Human-grounded eval. with non-experts
  - *Input + explanation*: simulate the model's output, what pred. expected
  - *Counterfactual simulation: *what must change to change prediction?
  === Functionally-grounded evaluation (math, formal, no humans)
  - *e.g.: * sparcity, monotonicity, model size, number of rules/prototypes
  - Fastest, but weakest evidence of human usefulness
  == Post-Hoc evaliation dimensions
  === Faithfulness: explanation = model behaviour?
  - *expert ground truth: *
  - _Feature agreement: _fraction of common features k-most important
  - _Sign agreement: __feature agreement_ *+ sign*
  - _Rank agreement: _ top k predicted and ground truth: same order
  - _Rank correlation:_ Spearman's rank correlation among ordered pred &gt
  - _Pairwise rank agreement:_ relative ordering of every pair is the same
  - *simpler model (LIME, model dist.):* fraction of samples that match
  - *Predictive faithfulness Methods:*
  - _Deletion: _ seq. removal most important features → *good:* first steep, then flat
  - _Insertions: _ start empty, add most important → *good:* first steep, then flat
  - _Pertubation: _ perturb first most important (should change), perturb unimportant (should not change)
  === Stability
  - *RIS: Relative Input Stability: *Small input change → explanation should change little.
  - *RRS: Relative Representation Stability: *Small latent/internal representation change → explanation should change little.
  - *ROS: Relative Output Stability: *Similar output probabilities → similar explanations.
  === Fairness
  - compute _Faithfulness, Stability_ per group → compare
  - *Important: * prediction fairness $!=$ explanation fairness, explanations can be better for one group
  === Clever Hans Effect
  shortcut learning (watermark) → faithful explanations help debug
]