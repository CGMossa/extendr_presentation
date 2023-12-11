// #import "@preview/polylux:0.3.1": *
#import "polylux/polylux.typ": *

#import themes.minimetropolis: *
#set math.text(font: "Fira Sans",
  weight: "medium",
  ligatures: true)
#set text(
  font: "New Computer Modern",
  ligatures: true, weight: "medium")

#set page(paper: "presentation-16-9")

// #show: university-theme.with(aspect-ratio: "16-9")
#show: metropolis-theme.with(
  aspect-ratio: "16-9"
)
#set text(size: 25pt)
// #set strong(delta: 100)
#show link: set text(fill: fuchsia)
// #set par(justify: true)

#show raw: set text(
  font: "Cascadia Code",
  weight: "medium",
  ligatures: true)

#let r = body => [
  // #show raw: set text(ligatures: true)
  #let body = if type(body) == content and body.func() == raw { body.text } else { body }
  #raw(lang: "r", body)
]

#let rust = body => [
  // #show raw: set text(ligatures: true)
  // SUGGESTION by PgSuper
  #let body = if type(body) == content and body.func() == raw { body.text } else { body }
  //
  #raw(lang: "rust", body)
]
  
#[
  #set text(size: 45pt)
  #title-slide(
    title: [`extendR`],
    subtitle: [Seamless integration between R and Rust],
    author: [
      #set text(size: 23pt)
      // #set text(justify: false)
      #set par(justify: false)
      Mossa Merhi Reimert, and others
      // "andy-thomason <andy@andythomason.com>",
      // "Thomas Down",
      // "Mossa Merhi Reimert <mossa@sund.ku.dk>",
      // "Claus O. Wilke <wilke@austin.utexas.edu>",
      // "Hiroaki Yutani",
      // "Ilia A. Kosenkov <ilia.kosenkov@outlook.com>",
      // "Michael Milton <michael.r.milton@gmail.com>",
      #box([
        #set text(size: 12pt)
        _Others_: Andy Thomason, Thomas Down, Claus O. Wilke, Hiroaki Yutani, Ilia A. Kosenkov, Michael Milton, 
      ])
    ]
  )
]

#slide(title: [Who uses R??])[
  #quote([R is a _free_ software environment for _statistical_ computing and graphics.]) -- #link("https://www.r-project.org/", "r-project.org").

  #pause

  - R is an interpreted language written in C.
  
  - R is the successor of S

  - Functional? Object-oriented? Imperative? 

  // Multi-paradigm? Robust? Stable? Etc.
]

#slide(
  title: [I'm Mossa.]
)[
  // #set align()
  // Formula training in (mathematical) Statistics,
  // (not )
  PhD Student in Veterinary Epidemiology, 
 
  MSc. in (mathematical) Statistics

  Interests: Simulator-based inference, Statistical inference

  Thesis is on Agent-based modelling of African Swine Fever between wild boars and domestic pigs


// #v(3em)

#grid(rows: 1, columns: 3,
  column-gutter: 3.5em,
  v(1.4em),
// #image("media/image7.png", width: 3em)
  grid(
    columns: 3, 
    image("media/image11.png", height: 3em),
    [ `<==>` ],
    image("media/image6.png", height: 3em)
  ),
  box(fill: red, height: 1.1em, clip: true, stroke: black)[
    DEADLINE: March 2024
  ]
)
  Supervisors: Matt Denwood, 	Maya Grussmann	Anette Boklund
]

#slide(title: [Why not R?])[
  R has many shortcomings
  // But in the context of disease modelling, 
  // 

  - Resource management (especially an issue when adding concurrency)
  
  - Concurrency support: Logging a model-run, should happen irrespective of the model calculations.
  
  - No auto-vectorisation, even summing flat numbers is difficult, see #link("https://www.wikiwand.com/en/Kahan_summation_algorithm", [Kahan Summation Algorithm])
]

#slide(title: [Why Rust?])[
  - Compiled language like C/C++ with similar performance
  
  - Declarative memory management, unlike C/C++
  - No exceptions
  - No object-oriented programming, dispatch based

  References:
  // #link("https://github.com/thoughtworks/epirust/wiki/Motivation-Behind-EpiRust", [Motivation Behind `EpiRust`]), by @kshirsagarEpiRustFrameworkLargescale2021, evaluating rust for ABMs
  // @antelmiEvaluatingRustProgramming2019; Lange group uses Rust for their ASF wild boar model
]

#slide()[
  // There are several frameworks for using agent-based modelling: 
  // @correaRustagentbasedmodels2023,
  // @KrABMaga2023,
  // @kshirsagarEpiRustFrameworkLargescale2021

  The goal isn't to make general-purpose framework.

  Instead, custom-built models in Rust, and have the ability to amend / interact with these in R...

  Hence, `extendR`!
  
]

#slide(title: [Why not our R models?])[

  They are convoluted, by design, as to make them work with R's computational constraints.
  // A "simple" construction will not be fast, i.e. using lists, and for-loops
  // An idea that comes in is using matrices / arrays, that
  // entails making all operations in that way
  // which  makes the model unreadable, as the operations performed are non-standard to R, (like shuffling)
  
  They are still slow. 
  
  - No ABC / SMC procedure can be built on top (to estimate epidemiological parameters on the available  data)
  
  - No sufficiently complex mechanism can be implemented in them.
  // Advanced dispersal for WB gets too complicated
  // - Running the WB Model together with the DPP Model wasn't going to work anyways
]

#slide(title: [What is `extendR`?])[
  
  `extendR` is composed of 3 parts:
  
  - System bindings through `libR-sys` \[Rust / requires C\]
  // Exposing R's C-API / C-facilities
  
  - `extendr` that contains an API, procedural macros, and engine. \[Rust\]
  
  - `rextendr` which is an R-package to use Rust, publish to CRAN, etc.

  See #link("https://extendr.github.io/").
]

#slide(title: [Getting started with `extendr`])[
  ```r
  remotes::install_github("extendr/rextendr")
  usethis::create_package("vetEpiRust")
  rextendr::use_extendr()
  ```
  Daily tool: #r("rextendr::document()").

  Rust project is in `vetEpiRust/src/rust/`.

  `rextendr` also have `rust_source` and `rust_function` equivalent to `Rcpp`'s functions..
]

#slide(title: [ExtendR features])[
  - Conversions between R and Rust types.
  
  - Interfacing from R into Rust, by generating wrappers / `.Call`
  
  - Interfacing from Rust to R, by emulating R inside of Rust, and accessing R's C-API single-threaded
  
  - Running R inside of Rust 
  
  - Publishing Rust-powered R-packages on CRAN
]

#slide(title: [`extendr`: Example])[
  ```rs
  
/// Return string `"Hello world!"` to R.
/// @export
#[extendr]
fn hello_world() -> &'static str {
    "Hello world!"
}
  ```
]
#slide(title: [`extendr`: Conversions])[
  #set text(size: 20pt)
  ```r
> hello_world()
[1] "Hello world!"
> .Internal(inspect(hello_world()))
@0x000001f379d4d6b0 16 STRSXP g0c1 [] (len=1, tl=0)
  @0x000001f3747398c8 09 CHARSXP g1c2 [MARK,REF(5),gp=0x60,ATT] [ASCII] [cached] "Hello world!"
  ```
  Regular R:
  ```r
  > .Internal(inspect("Hello world!"))
@0x000001f3797b0510 16 STRSXP g0c1 [REF(2)] (len=1, tl=0)
  @0x000001f3747398c8 09 CHARSXP g1c2 [MARK,REF(6),gp=0x60,ATT] [ASCII] [cached] "Hello world!"
  ```
]

#slide(title: [`extendr`: Conversions])[
  There are only #r("integer()") / #rust("i32") and #r("numeric()") / #rust("f64").

  For R to use a value, it needs to be allocated by R.
  
  For Rust to use a value, it can be allocated in either.

  *But R's API is single-threaded.*
]

#slide(title: [`extendr` allocations])[
  Currently, `extendr` protects everything it allocates via R's C-API.

  Thus, `extendr` protects things that don't need protection.

  `R` supports local protection mechanism, which are efficient, and global protection mechanism, which are slower.

  ExtendR provides `Logicals`, `Integers`, `Doubles`, etc.
  and we can access them as native Rust slices, i.e. `&[T]` / `&mut [T]`. 
]

#slide(title: [`extendr`'s protection / `ownership`-module])[
  Currently, `extendr` treats `SEXP`s as Reference Counted variables.

  My proposal is to move into #rust("Box<_>") / #raw(lang:"c++", "std::unique_ptr") way of thinking.
  
]

#slide(title: [Currently, `Robj` is...])[
  ```rs
  pub struct Robj {
      inner: SEXP,
  }
  ```
  Creating `Robj` incurs a registration in `ownership-module`, encurs a registration, not an increase in RC.
  
]

#slide(title: [Proposal])[
  ```rs
  pub enum Robj {
    /// Protected by R, or a symbol
    Permanent(RawRobj),
    /// Unprotected / free R object
    Raw(RawRobj),
    /// Owned (by Rust), meaning it has to be freed by Rust
    Owned(RawRobj),
}
  ```

  More on this on #link("https://github.com/extendr/extendr/issues/608", "#608") on GitHub...
]

#slide(title: [Why is this an issue?])[
  - Allocating large vectors requires that we protect / unprotect locally. 
  
    Using `PROTECT` / `UNPROTECT` is not possible, because there is an arbitrary limit of #sym.approx 10k on `PROTECT`-calls.

  - Benchmarks against `{Rcpp}`...
  
]

#slide(title: [Vision: Use R-data and Rust-data in unison!])[
  Embedding Rust data in R is done through 
  #rust(`ExternalPtr<T>`)#footnote(link("https://cran.r-project.org/doc/manuals/R-exts.html#External-pointers-and-weak-references", [External pointers and Weak references in R-exts.]))

  ```C
  SEXP R_MakeExternalPtr(void *p, SEXP tag, SEXP prot);
  ```

  `tag` is an identifier for type,
  `prot` are accompanying R-data that is protected as long as `ExternalPtr<T>` is alive.

  ... there are other stuff
  
]

#slide(title: [Vision])[
  #side-by-side(
    [
    ```rust
    #[extendr]
    struct Scenario {
      rust_data: Vec<i32>,
      #[extendr]
      r_data: Integers
      #[extendr(readonly)]
      r_data_2: Rint,
      // ???
      ambigious_data: LikeRobj,
    }
    ``` 
    ],
    [
      For methods, we already have
      ```rs
      #[extendr]
      impl Scenario {
        pub fn update(&mut self) {
          todo!()
        }
      }
      ```
    ]
  )
  // Register `r_data` in `prot`, and respect `pub`-status.
]

#slide(title: [Vision])[
  This enables composing R and Rust function, because both can interact with each other.

  \ \

_  Prerequisites for this: Emulating R-data in Rust, interfacing without reallocation, generation of wrappers..
_]

#slide(title: [`extendr`'s R Exporting / Namespace])[
  An R-package is a `DESCRIPTION` + `NAMESPACE`.
  // a description is which namespaces are imported,
  // and which are names are  exported

  An R-package has only one namespace #sym.subset module.

  `#[extendr]` exports to R, and `@export` exports to `NAMESPACE`, i.e. other R-packages.

  ```rust
  extendr_module! {
      mod vetEpiRust;
      fn hello_world;
  }
  ```
]

#slide(title: [`extendr` another module?])[
  ```rs
    extendr_module! {
        mod wild_boar_model;
        use landscape_generation;
        use distance_weights_function;
        impl sir_model;
        fn run_until_outbreak;
    }
  ```
  `mod` defines current module, `use` exports another module, `fn` exports a function, `impl` exports a Rust `struct`.
]


#slide(title: [References])[
    #set text(size: 18pt)
    
    // #bibliography("assessment.bib", title: none)
]


#focus-slide([
  #set text(size: 69pt)
  _*Graveyard*_])


#slide(title: [What's an ECS])[
  ECS is analogous to a database, i.e. `World`-type.

  By describing entities (ids), to components (data), and systems (functions that requests `(id, data)`), it infers the *tables*#footnote("Archetypal storage") that the database should contain.

  Functions describe which table they require, and the database caches this.
]


#slide(title: [Advantages of an ECS])[
  Use an Entity Component System to build the model, and configure it with and w/e self-correcting processes

  Describe and demonstrate: 
  
  - Concurrent logging & sparse logging due to change-detection in ECS frameworks
  
  - Batched scenario repetitions by using Entity Relations in ECS framework
]

// #slide(title: [Flecs])[
  
// ]
