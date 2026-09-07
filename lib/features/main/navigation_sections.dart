const sectionIds = [
  'home-screen',
  'fine-match-screen',
  'beer-simple-screen',
  'statistics-hub',
  'more-hub',
];
bool showsMainNavigation(String id) =>
    const ['home-screen', 'more-hub'].contains(id);
bool isMainSection(String id) => sectionIds.contains(id);
