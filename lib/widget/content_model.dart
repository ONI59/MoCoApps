class UnboardingContent{
  String image;
  String title;
  String description;
  UnboardingContent({required this.description, required this.image, required this.title});
}

List<UnboardingContent> contents=[
  UnboardingContent(
      description: 'Lets Explore various coffe flavors\nwith us with just few clicks',
      image: "images/welcome.png",
      title: 'Let\'Explore\nKinds of coffe'),
  UnboardingContent(
      description: 'Monitor the state of the cafe and\nvisit with your friends',
      image: "images/Welcome3.png",
      title: 'Monitor and\nvisit the cafe'),
  UnboardingContent(
      description: 'Get ready to try the newest coffe\nvariant your friends',
      image: "images/Welcome4.jpg",
      title: 'Get ready for the\nnewest coffe')
];