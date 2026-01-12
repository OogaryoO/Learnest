class Resource {
  String url;

  Resource(this.url);

  static toMap(Resource resource){
    return{
      "url": resource.url
    };
  }

  static List<Resource> fromPendingList(List<dynamic>? list){
    return list
        ?.whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map(Resource.new)
        .toList() ?? [];
  }
}