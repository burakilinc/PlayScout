/// Maps to `ChildAgeMonths` query param (upper bound of band).
enum FilterAgeBand {
  zeroTwo(24),
  threeFive(60),
  sixTen(120);

  const FilterAgeBand(this.childAgeMonths);
  final int childAgeMonths;
}
