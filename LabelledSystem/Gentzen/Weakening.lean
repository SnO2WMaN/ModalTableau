import LabelledSystem.Gentzen.ReplaceLabel

lemma Multiset.map_id_domain {s : Multiset α} (hf : ∀ a ∈ s, f a = a) : s.map f = s := by
  rw [Multiset.map_congr rfl hf];
  exact Multiset.map_id' s

namespace LO.Modal.Labelled.Gentzen

open SequentPart
open DerivationWithHeight

noncomputable def wkFmlLₕ (d : ⊢ᵍ[k] S) : ⊢ᵍ[k] ⟨(x ∶ φ) ::ₘ S.Γ.fmls, S.Γ.rels⟩ ⟹ S.Δ := by
  induction d using DerivationWithHeight.rec' generalizing x with
  | hAtom y a => exact initAtom_memₕ y a (by simp) (by simp);
  | hBot y => exact initBot_memₕ y (by simp);
  | @hImpR S y ψ χ k d ih =>
    suffices ⊢ᵍ[k + 1]
      ⟨(x ∶ φ) ::ₘ S.Γ.fmls, S.Γ.rels⟩ ⟹ ⟨(y ∶ ψ ➝ χ) ::ₘ S.Δ.fmls, S.Δ.rels⟩
      by simpa;
    refine impRₕ
      (S := ⟨(x ∶ φ) ::ₘ S.Γ.fmls, S.Γ.rels⟩ ⟹ S.Δ)
      (x := y) (φ := ψ) (ψ := χ) $ ?_;
    . exact exchangeFmlLₕ $ ih;
  | @hImpL S y ψ ξ k₁ k₂ d₁ d₂ ih₁ ih₂ =>
    suffices ⊢ᵍ[max k₁ k₂ + 1]
      ⟨(x ∶ φ) ::ₘ (y ∶ ψ ➝ ξ) ::ₘ S.Γ.fmls, S.Γ.rels⟩ ⟹ S.Δ
      by simpa;
    refine exchangeFmlLₕ $ impLₕ
      (S := ⟨(x ∶ φ) ::ₘ S.Γ.fmls, S.Γ.rels⟩ ⟹ S.Δ)
      (x := y) (φ := ψ) (ψ := ξ) ?_ ?_;
    . exact ih₁;
    . exact exchangeFmlLₕ $ ih₂;
  | @hBoxL S y z ψ k d ih =>
    suffices ⊢ᵍ[k + 1]
      ⟨(x ∶ φ) ::ₘ (y ∶ □ψ) ::ₘ S.Γ.fmls, (y, z) ::ₘ S.Γ.rels⟩ ⟹ S.Δ
      by simpa;
    refine exchangeFmlLₕ $ @boxLₕ
      (S := ⟨(x ∶ φ) ::ₘ S.Γ.fmls, S.Γ.rels⟩ ⟹ S.Δ)
      (x := y) (y := z) (φ := ψ) (k := k) ?_;
    . exact exchangeFml₃Lₕ $ ih;
  | @hBoxR S y z hyz hΓz hΔz ψ k d ih =>
    suffices ⊢ᵍ[k + 1]
      ⟨(x ∶ φ) ::ₘ S.Γ.fmls, S.Γ.rels⟩ ⟹ ⟨(y ∶ □ψ) ::ₘ S.Δ.fmls, S.Δ.rels⟩
      by simpa;
    by_cases e : z = x;
    . subst e;
      let w : Label := ((⟨(z ∶ φ) ::ₘ S.Γ.fmls, (y, z) ::ₘ S.Γ.rels⟩) ⟹ S.Δ).getFreshLabel;
      have := boxRₕ
        (S := ⟨(w ∶ φ) ::ₘ S.Γ.fmls, S.Γ.rels⟩ ⟹ S.Δ)
        (k := k) y z ψ hyz ?_ ?_ $ by simpa using @ih w;
      have := @replaceLabelₕAux'
        (x := w) (y := z) (k := k + 1)
        (S := { fmls := (w ∶ φ) ::ₘ S.Γ.fmls, rels := S.Γ.rels } ⟹ { fmls := (y ∶ □ψ) ::ₘ S.Δ.fmls, rels := S.Δ.rels })
        this;
      simp at this;
      have e₁ : S.Γ.fmls.map (.labelReplace (w ↦ z)) = S.Γ.fmls := by
        apply Multiset.map_id_domain;
        rintro ⟨l, ξ⟩ hlξ;
        apply LabelledFormula.labelReplace_specific_not;
        have : (w ∶ ξ) ∉ S.Γ.fmls := not_include_labelledFml_of_isFreshLabel ?_ ξ;
        rintro rfl;
        contradiction;
        apply getFreshLabel_mono (Δ := ⟨(w ∶ φ) ::ₘ S.Γ.fmls, S.Γ.rels⟩);
        . simp [Multiset.subset_cons];
        . rfl;
      have e₂ : S.Δ.fmls.map (.labelReplace (w ↦ z)) = S.Δ.fmls := by
        apply Multiset.map_id_domain;
        intro ⟨l, ξ⟩ hlξ;
        apply LabelledFormula.labelReplace_specific_not;
        rintro rfl;
        have : (w ∶ ξ) ∉ S.Δ.fmls := not_include_labelledFml_of_isFreshLabel ?_ ξ;
        contradiction;
        exact Sequent.getFreshLabel_isFreshLabel₂;
      have e₃ : S.Γ.rels.map (.labelReplace (w ↦ z)) = S.Γ.rels := by
        apply Multiset.map_id_domain;
        intro ⟨l₁, l₂⟩ hl;
        apply LabelTerm.labelReplace_specific_not_both;
        . rintro rfl;
          have : (w, l₂) ∉ S.Γ.rels := not_include_relTerm_of_isFreshLabel₁ ?_ l₂;
          contradiction;
          exact Sequent.getFreshLabel_isFreshLabel₁;
        . rintro rfl;
          have : (l₁, w) ∉ S.Γ.rels := not_include_relTerm_of_isFreshLabel₂ ?_ l₁;
          contradiction;
          exact Sequent.getFreshLabel_isFreshLabel₁;
      have e₄ : S.Δ.rels.map (.labelReplace (w ↦ z)) = S.Δ.rels := by
        apply Multiset.map_id_domain;
        intro ⟨l₁, l₂⟩ hl;
        apply LabelTerm.labelReplace_specific_not_both;
        . rintro rfl;
          have : (w, l₂) ∉ S.Δ.rels := not_include_relTerm_of_isFreshLabel₁ ?_ l₂;
          contradiction;
          exact Sequent.getFreshLabel_isFreshLabel₂;
        . rintro rfl;
          have : (l₁, w) ∉ S.Δ.rels := not_include_relTerm_of_isFreshLabel₂ ?_ l₁;
          contradiction;
          exact Sequent.getFreshLabel_isFreshLabel₂;
      have e₅ : ((w ↦ z) y ∶ □ψ) = (y ∶ □ψ) := by
        apply LabelledFormula.labelReplace_specific_not;
        apply Ne.symm;
        apply Sequent.getFreshLabel_relΓ₁ (y := z);
        simp;
      simpa [e₁, e₂, e₃, e₄, e₅] using this;
      . apply of_isFreshLabel;
        . intro ξ;
          suffices (w ≠ z) ∧ (z ∶ ξ) ∉ S.Γ.fmls by simp; constructor <;> tauto;
          constructor;
          . apply Sequent.getFreshLabel_ne₁ (φ := φ) (by simp);
          . apply not_include_labelledFml_of_isFreshLabel hΓz ξ;
        . apply not_include_relTerm_of_isFreshLabel₁ hΓz;
        . apply not_include_relTerm_of_isFreshLabel₂ hΓz;
      . apply of_isFreshLabel;
        . apply not_include_labelledFml_of_isFreshLabel hΔz;
        . apply not_include_relTerm_of_isFreshLabel₁ hΔz;
        . apply not_include_relTerm_of_isFreshLabel₂ hΔz;
    . refine boxRₕ (S := ⟨(x ∶ φ) ::ₘ S.Γ.fmls, S.Γ.rels⟩ ⟹ S.Δ) (k := k) y z ψ hyz ?_ ?_ ?_;
      . apply of_isFreshLabel;
        . intro ξ;
          suffices (z = x → ¬ξ = φ) ∧ (z ∶ ξ) ∉ S.Γ.fmls by simpa;
          constructor;
          . tauto;
          . exact not_include_labelledFml_of_isFreshLabel hΓz ξ;
        . apply not_include_relTerm_of_isFreshLabel₁ hΓz;
        . apply not_include_relTerm_of_isFreshLabel₂ hΓz;
      . apply of_isFreshLabel;
        . apply not_include_labelledFml_of_isFreshLabel hΔz;
        . apply not_include_relTerm_of_isFreshLabel₁ hΔz;
        . apply not_include_relTerm_of_isFreshLabel₂ hΔz;
      . exact ih;

noncomputable def wkFmlL (d : ⊢ᵍ S) : ⊢ᵍ ⟨(x ∶ φ) ::ₘ S.Γ.fmls, S.Γ.rels⟩ ⟹ S.Δ := wkFmlLₕ (d := .ofDerivation d) |>.drv


def wkRelLₕ (d : ⊢ᵍ[h] Γ ⟹ Δ) : ⊢ᵍ[h] ⟨Γ.fmls, (x, y) ::ₘ Γ.rels⟩ ⟹ Δ := by sorry

def wkRelL (d : ⊢ᵍ Γ ⟹ Δ) : ⊢ᵍ ⟨Γ.fmls, (x, y) ::ₘ Γ.rels⟩ ⟹ Δ := wkRelLₕ (d := .ofDerivation d) |>.drv


def wkFmlRₕ (d : ⊢ᵍ[h] Γ ⟹ Δ) : ⊢ᵍ[h] Γ ⟹ ⟨(x ∶ φ) ::ₘ Δ.fmls, Δ.rels⟩ := by sorry

def wkFmlR (d : ⊢ᵍ Γ ⟹ Δ) : ⊢ᵍ Γ ⟹ ⟨(x ∶ φ) ::ₘ Δ.fmls, Δ.rels⟩ := wkFmlRₕ (d := .ofDerivation d) |>.drv


def wkRelRₕ (d : ⊢ᵍ[h] Γ ⟹ Δ) : ⊢ᵍ[h] Γ ⟹ ⟨Δ.fmls, (x, y) ::ₘ Δ.rels⟩ := by sorry

def wkRelR (d : ⊢ᵍ Γ ⟹ Δ) : ⊢ᵍ Γ ⟹ ⟨Δ.fmls, (x, y) ::ₘ Δ.rels⟩ := wkRelRₕ (d := .ofDerivation d) |>.drv

end LO.Modal.Labelled.Gentzen