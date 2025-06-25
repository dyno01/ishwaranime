import 'package:dartotsu/Functions/Extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:provider/provider.dart';

import '../../Adaptor/Media/MediaAdaptor.dart';
import '../../Adaptor/Media/Widgets/Chips.dart';
import '../../Adaptor/Media/Widgets/MediaCard.dart';
import '../../Animation/SlideInAnimation.dart';
import '../../Functions/Function.dart';
import '../../Services/Screens/BaseMangaScreen.dart';
import '../../Services/ServiceSwitcher.dart';
import '../../Theme/Colors.dart';
import '../../Theme/LanguageSwitcher.dart';
import '../../Theme/ThemeProvider.dart';
import '../../Widgets/ScrollConfig.dart';
import '../Home/Widgets/LoadingWidget.dart';
import '../Home/Widgets/ServiceSwitcherBar.dart';

class MangaScreen extends StatefulWidget {
  const MangaScreen({super.key});

  @override
  MangaScreenState createState() => MangaScreenState();
}

class MangaScreenState extends State<MangaScreen> {
  @override
  Widget build(BuildContext context) {
    var service = Provider.of<MediaServiceProvider>(context).currentService;
    var screen = service.mangaScreen;
    if (screen == null) {
      return service.notImplemented(widget.runtimeType.toString());
    }
    screen.init();
    return Scaffold(
      body: Stack(
        children: [
          _buildRefreshContent(screen),
          _buildScrollToTopButton(screen),
        ],
      ),
    );
  }

  Widget _buildRefreshContent(BaseMangaScreen service) {
    return RefreshIndicator(
      onRefresh: () async => Refresh.activity[service.refreshID]?.value = true,
      child: CustomScrollConfig(
        context,
        controller: service.scrollController,
        children: [
          SliverToBoxAdapter(child: _buildMangaScreenContent(service)),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Obx(() => _buildMediaContent(service)),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollToTopButton(BaseMangaScreen service) {
    var theme = Provider.of<ThemeNotifier>(context);
    return Positioned(
      bottom: 72.0 + 32.bottomBar(),
      left: (0.screenWidthWithContext(context) / 2) - 24.0,
      child: Obx(() => service.scrollToTop.value
          ? Container(
              decoration: BoxDecoration(
                color: theme.isDarkMode ? greyNavDark : greyNavLight,
                borderRadius: BorderRadius.circular(64.0),
              ),
              padding: const EdgeInsets.all(4.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed: () => service.scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                ),
              ),
            )
          : const SizedBox()),
    );
  }

  Widget _buildMangaScreenContent(BaseMangaScreen service) {
    return Obx(() {
      var mediaDataList = service.trending.value;
      return SizedBox(
        height: 486.statusBar(),
        child: service.running.value
            ? Stack(
                children: [
                  SizedBox(
                    height: 464.statusBar(),
                    child: mediaDataList != null
                        ? MediaAdaptor(type: 1, mediaList: mediaDataList)
                        : const Center(child: CircularProgressIndicator()),
                  ),
                  ServiceSwitcherBar(
                    title: getString.manga.toUpperCase(),
                  ),
                  Positioned(
                    bottom: 92,
                    left: 8.0,
                    right: 8.0,
                    child: Center(
                      child: ChipsWidget(
                        chips: service.trendingChips,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 8.0,
                    right: 8.0,
                    child: SlideInAnimation(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MediaCard(
                            context,
                            getString.genres,
                            "https://s4.anilist.co/file/anilistcdn/media/manga/banner/105778-wk5qQ7zAaTGl.jpg",
                            onTap: () {},
                          ),
                          MediaCard(
                            context,
                            'TOP SCORE',
                            "https://s4.anilist.co/file/anilistcdn/media/manga/banner/30002-3TuoSMl20fUX.jpg",
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              )
            : const LoadingWidget(),
      );
    });
  }

  Widget _buildMediaContent(BaseMangaScreen service) {
    return Column(
      children: [
        ...service.mediaContent(context),
        if (service.paging)
          SizedBox(
            height: 216,
            child: Center(
              child: !service.loadMore.value && service.canLoadMore.value
                  ? const CircularProgressIndicator()
                  : const SizedBox(height: 216),
            ),
          ),
      ],
    );
  }
}
