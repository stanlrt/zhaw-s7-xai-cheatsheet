#import "@preview/simple-cheatsheet:0.1.0": cheatsheet, container

#show: cheatsheet.with(
  info: (
    title: "XAI",
    authors: ("Jonas Vonderhagen, not so much: Stanislas Laurent",),
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

  == Local feature attribution
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
  === Anchors
  *Local* rule-based *model-agnostic*: find minimal set of features to lock-in prediction with high probability → changes other feature values → same prediction (IF-ELSE-Rules)
  - *How: * map local neighbourhood by generating multiple perturbed instances around target instance
  - *Optimization: * muti-arm bandit optimization → high precision and beam search to max. coverage of the neighbourhood
  - *Images: *Use superpixels obtained through image segementation
  === SHAP: Feature importance
  *Collab. game theory: * how much each feature contributed with _fair distribution_ (features add up, rewards +/-, interchangable players equal rewards, no effect → 0 contrib.) + _interaction_
  
  *Local, Post-Hoc* _KernelSHAP_: model agnostic approximation; _TreeSHAP, LinearSHAP_: model-specific, exact
  - Start from the baseline prediction: $E[f(x)]$
  - Add features in the given order.
  - Each SHAP value is the jump in expected prediction.
  
  For order: $"Age" -> "Income"$
  
  $phi_"Age" =
    E[f(x) | "Age" = 30] - E[f(x)]$
  
  $phi_"Income" =
    E[f(x) | "Age" = 30, "Income" = "60K"]
    - E[f(x) | "Age" = 30]$
  - *LinearSHAP:*exact for linear models.
    $phi_i = beta_i (x_i - E[X_i])$
  - *TreeSHAP:* exact for tree models.
    For each subset $S$, follow known feature splits.
    If a split feature is missing, follow both branches weighted by training-data proportions.
    Then plug the resulting $v(S)$ values into the SHAP formula.
  - *KernelSHAP:* model-agnostic approximation.
    Sample feature subsets, replace missing features by background values,
    query the black-box model, then fit a weighted linear model:
    $g(z') = phi_0 + sum_i phi_i z'_i$
    The fitted coefficients $phi_i$ are the SHAP values
]

= Saliency
#container[
  == Saliency Maps / Pixel Attribution
  - *Goal:* Which input pixels/features are most relevant for _target class_
  - *Type:* local, post-hoc, model-specific
  - Backpropagation to compute gradients of class score w.r.t input
  - for class c: $ M_c(x) = (partial S_c(x)) / (partial x) $
  - *Interpretation:* large gradient = small pixel change strongly changes class score.
  - *Output:* heatmap with same size as input image.
  - *Problems: *noisy (local deriv. vary strong), ReLU saturation (- ignored)
  === Variants
  - *SmoothGrad:* - noise: adding gaussian noise (10-20%) to input → avg
  - *Gradient x Input:* Multiply input gradients element-wise with original → _idea:_ important features have high input value + high gradient → more stable
  == CAM: Class Activation Mapping
  - Works for CNNs with *Global Average Pooling, GAP*: sum feature maps for each channel $->$ param free/reduce dimensionality, sum out spacial info, Interpretability: weight of linear layer $->$ imporance of spacial features for class $->$ final class score = linear combin. feature maps
  === Grad-CAM: Generalization for many non GAP-CNNs
  - Uses *Gradients* of class scores w.r.t. last convolutional feature maps
  - Gradient is only backpropagated to the *last conv. layer* not to input
  - Produces coarse but more human-interpretable heatmaps
  1. compute gradient of class score w.r.t feature maps: $ alpha_k^c = 1/(H W) sum_i sum_j (partial y^c) / (partial A_"ij"^k) $
  2. Grad-CAM heatmap for class c (only + influence (ReLU): $ L_("Grad-CAM")^c = "ReLU"(sum_(k=1)^K alpha_k^c A^k) $ 
  === LRP: Layer-Wise Relevance Propagation
  - *Type:* *local, post-hoc, model-specific* for NNs: Starts from prediction score and propagates “relevance” backwards layer by layer.
  - *Main principle*: Relevance conservation ($a_j$: activ. neuron $j$; $w_"ji"$: weight neuron $j$ to neuron $i$; $l$: layer; $R_i$: Relevance neuron $i$)
  $ R_j^((l)) = sum_i (a_j^((l)) w_"ji"^((l))) / (sum_j a_j^((l)) w_"ji"^((l)) + epsilon) R_i^((l+1)) $
  - $+$ satisfies sensitivity; $-$ violates impl. invariance: NN layer structure
  == Integrated Gradients: Attribution method using baseline input
  - *Baseline:* represents absence of signal, e.g. black image
  - Integrates gradients along straight path: baseline $x'$ to target input $x$
  $ "IG"_i^(approx)(x) = (x_i - x'_i) times 1/m sum_(k=1)^m (partial F(x' + k/m (x - x'))) / (partial x_i) $
  - Satisfies all 4 properties: _Completeness_, _Sensitivity_, _Implementation Invariance_, _Linearity_
  - *Problems:* Baseline choice difficult (no signal), no interaction
  == Global Model Agnostic XAI approaches
  === Model distillation: Interpretable model mimics black-box
  - E.g.: decision tree, GAM, decision set
  - *Model-agnostic*: only needs inputs + black-box predictions
  - 1. train black-box $x->y$; 2.train interpretable($y^*$): $x->hat(y)$; 3. check alignment $hat(y)<>y^*$; 4. use well-aligned surrogate to interpret $hat(y)$
  - Good surrogate should have high surrogate alignment: $ R^2 approx 1$
  === SP-LIME: sub-modular pick LIME
  - many *local* LIME explanations $->$ *global* explanation
  - Greedily select $k$ explanations: _representative, diverse, non-redundant_
  - 1. empty $"set(E)"$; 2. Add instance + largest feature coverage increase (min. overlapping); 3. stop after $k$ explanation instances
  === PDP: Partial Dependence Plot
  - measure *marginal impact of a target feature* on prediction, *others fixed*
  - 1. select target feature; 2. vary across plausible range; 3. compute pred. for each variation; 4. avg. pred. over all dataset samples
  - More variation in PDP $->$ more important
  - *Disadvantages:* not high-dim data, no feature interactions, unrealistic feature combinations
  === ALE: Accumulated Local Effects
  - Change feature values only locally: avoid unrealistic combinations
  - *Bins:* samples in each bin: set feat. lower boundary, set feat upper b. $->$ compute pred. difference $->$ avg. local diffs $->$ accumulate
]

= Sample Importance & Counterfactuals
#container[
  - *Main questions: * important samples for pred., input kinds misclasified, what input max. activates a neuron of interest?
  == Influence functions
  - *Goal:* estimate importance of training sample $z$ for pred. test sample
  - *Approach:* _1. order Taylor approximation_: simul. leave-one-out retrain
  $ I_("up,params")(z) = -H^(-1) nabla_theta L(z, hat(theta)) $
  - *Intuition:* gradient = how strongly sample pushes params; $H^(-1)$ = corrects for curvature / how easily model moves
  - *Removal of sample:* each sample has weight $1/n$, so removing $z$ approx. means $epsilon = -1/n$
  $ hat(theta)_(-z) - hat(theta) approx -1/n I_("up,params")(z) $
  - *Influence on test loss:*
  $ I_("up,loss")(z, z_("test")) = - nabla_theta L(z_("test"), hat(theta))^T H^(-1) nabla_theta L(z, hat(theta)) $
  - *Interpretation:* large abs. influence = training point strongly affects test pred.; positive = harmful, negative = helpful
  - *Example:* if removing one point changes pred. $35% -> 75%$, that point is highly influential (possibly mislabeled)
  - *Pros:* fast approx. of leave-one-out
  - *Cons:* Hessian expensive; not model-agnostic; less reliable/accurate for deep non-convex NNs

  == Activation Maximisation
  - *Goal:* find natural/synthetic inputs that strongly activate neuron / channel / class
  - *Two variants:* pick strongest real examples from dataset; or synthesize input
  - *Optimisation:* *gradient ascent* on input: 
    $ x_(t+1) = x_t + eta (partial a_j(x_t)) / (partial x) $
  - *Use:* shows what pattern neuron/class/channel/layer is looking for
  - *Note:* dataset examples = what activates in practice; synthetic examples = what maximally activates
  == Counterfactuals
  - *Question:* what minimal changes to $x$ make model output desired $y'$? 
  - *Counterfactual:* changed input $x'$ with different prediction 
  - *Recourse:* actionable CF, e.g. rej. loan $->$ approved: "increase income"
  === Minimum distance counterfactuals
$ x_("cf") = arg min_(x') max_lambda lambda (f_w(x') - y')^2 + d(x,x') $
  - prediction-loss term flips output; distance term keeps $x'$ close to $x$
  - optimise w. ADAM *(needs gradients)* + random restarts; increase $lambda$
  - *Problem:* infeasible CFs possible, e.g. race
  === Feasible and Least cost Counterfactuals
  - restrict to feasible changes $A$: income yes, race/age no 
  - minimize *cost*, not only distance: $90% -> 95%$ harder than $50% -> 55%$ 
  - *Limitation:* mainly linear models; ignores feature interactions
  === Causal CF with Structural Causal Model 
  - uses *SCM* to respect causal dependencies between features 
  - *Goal*: minimal intervention, not minimal raw distance
  - e.g. loan: depends on salary+balance $->$ +salary $->$ +balance
  === Counterfactuals on Data Manifold
  - no SCM? train VAE; search CF in latent space; compress data 
  - realistic/high data density CFs; classifier-agnostic; tabular data 
  === 5. Global CF summaries: AReS
  - model-agnostic global recourse rules for subgroups 
  - optimises: correctness, coverage, interpretability, recourse cost 
  - use: detect biased/different recourse across groups
]


= Mechanistic interpretability
#container[
  - *Goal:* Reverse-engineering $->$ study model internals/model cognition
  - *Idea:* model = learned concepts + circuits/algorithms connecting them  == Features vs. Circuits
  - *Features/Concepts: * What does the model know? e.g. holiday neuron
  - *Circuits/Functions: *e.g. windows + wheels + car body -> car detector
  == Transformers
  - *Use:* sequence data; attention gives context-aware token representations 
  - *Q/K/V intuition:* Query = what token asks for; Key = what token can match; Value = information contributed $ "Attention"(X) = V[X] dot "softmax"(K[X]^T Q[X]) $ 
  - attention weights sum to 1; output = weighted sum of values 
  - *Problem:* self-attention has no order info -> need positional encoding 
  - *Multi-head:* parallel attention heads -> more capacity 
  - *LLMs:* tokens -> embeddings + pos. enc. -> transformer blocks -> softmax next-token probs
  === Circuit discovery workflow 
  1. choose task/behaviour + matching dataset, e.g. greater-than task: "1732 to 17??" -> output must be > 32 
  2. represent model internals as DAG:
  - coarse: attention heads / MLPs 
  - granular: neurons 
  3. prune graph via *activation patching* start at output: corrupt $a$ $->$ output change $<tau$ $->$ unimportant $->$ remove edge
  === ACDC: Automatically Discovering Circuits
  - Input: computational graph, dataset, corrupted data, threshold $tau$ - Iterate output -> input; try removing incoming edges
  - Use KL-Divergence recursively: remove if smaller than $tau$
  - *manual choices: *granularity, metric, threshold, corrupted samples
  === Polysemanticity / Superposition 
  - *Problem:* neurons are often not monosemantic 
  - *Polysemantic neuron:* one neuron responds to multiple concepts 
  - Especially in LLMs; CNN neurons more often cleaner 
  - *Superposition:* model represents more features than dimensions by mixing concepts in same neurons 
  - *Intuition*: small network simulates larger sparse network
  === Sparse Autoencoders
  - *Goal:* find interpretable latent features not captured by single neurons 
  - Learn sparse, overcomplete feature space $S$ for activations $H$ 
  - *sparse*: activation = few active features; *overcomplete:* more features than original dimensions 
  - Encoder outputs = feature activations 
  - Decoder columns = feature directions 
  - Examples: Arabic-script feature, DNA-sequence feature 
  - *Use:* discover concepts, measure contribution, monitor safety concepts, intervene on model behaviour
]

= Post-Hoc concept based methods
#container[
  - *Why concepts?* pixel/feature attributions often not semantically meaningful, not actionable, unstable/adversarially manipulable 
  - *Concepts:* high-level human-understandable units, e.g. stripes, wheels
  - Concepts can be *pre-defined* or *discovered from data* 
  - NNs naturally learn concepts: lower layers -> textures/surfaces; higher layers -> semantic concepts
  === T-CAV: Testing with Concept Activation Vectors
  - *Goal:* how much a user-defined concept influences pred. of class $k$ 
  - *Type:* post-hoc, concept-based, global for class, needs NN internals 
  - Concepts are defined domain experts/users, e.g. "stripes" for zebra
  1. choose intermediate layer $f_l$ 2. collect concept examples + random examples 3. train linear classifier in activation space 4. CAV = normal vector to classifier boundary 5. compute directional derivative: $ S_(C,k,l)(x) = nabla h_(l,k)(f_l(x)) dot v_C^l $ 
  - $S > 0$: increasing concept $C$ increases class-$k$ prediction
  - *TCAV score:* fraction of class-$k$ inputs pos. influenced by concept $C$
  - *Limitations:* need pre-defined concepts + labelled examples
  === ACE: Automatic Concept Extraction
  - *Goal:* automatically discover meaningful visual concepts
  - *Idea:* common image patches/superpixels across a class = concepts 
  - *Meaningfulness:* segment imgs at multiple resolutions -> superpixels 
  - *Coherence:* encode patches w. pretr. CNN, cluster similar, - outliers 
  - *Importance:* apply TCAV to discovered concepts
  - *Smallest suff. concepts:* few top concepts to recover much accuracy 
  - *Smallest destroying c.:* remove top concepts cause many misclass.
  - *Limitations:* only images/pixel patches; miss rare concepts (outliers)
  === CCE: Completeness-Aware Concept Extraction
  - *Goal:* discover complete concept set sufficient to explain prediction 
  - Decompose model: $ x -> Phi(x) = h -> f(h) -> y $ 
  - Learn concept vectors $C = [c_1, ..., c_m]$ 
  - *Completeness intuition:* if hidden state $h$ is projected to concept space and reconstructed, model accuracy should stay high 
  - *Score close to 1*: concepts preserve almost all info needed for prediction; *Score close to 0*: concepts no better than random
  - *1.* project hidden layer $h$ into concept space *2.* compute norm. concept scores *3.* train $g$ to reconstruct $h$ from concept scores *4.* pass reconstructed $hat(h)$ $->$ rest of model *5.* optimise concepts for high completeness
  - *Regularisers:* *Coherence:* similar samples close in concept space; *Diversity:* concepts should differ, avoid duplicates 
  - *ConceptSHAP:* fair contribution score of each concept to completeness 
  - *Advantage:* can work beyond images, e.g. text 
  - *Limit:* more complex; discov. concepts may still need human interpret
  
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



