import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:foddies_app/controllers/popular_product_controller.dart';
import 'package:foddies_app/models/products_model.dart';
import 'package:foddies_app/pages/food/popular_food_detail.dart';
import 'package:foddies_app/routes/route_helper.dart';
import 'package:foddies_app/utils/app_consts.dart';
import 'package:foddies_app/utils/dimensions.dart';
import 'package:foddies_app/widgets/app_column.dart';
import 'package:get/get.dart';
import '../../controllers/recommended_product_controller.dart';
import '/utils/colors.dart';
import '/widgets/big_text.dart';
import '/widgets/icon_and_text_widget.dart';
import '/widgets/small_text.dart';
import 'package:gap/gap.dart';

class FoodPageBody extends StatefulWidget {
  const FoodPageBody({Key? key}) : super(key: key);

  @override
  State<FoodPageBody> createState() => _FoodPageBodyState();
}

class _FoodPageBodyState extends State<FoodPageBody> {
  //control the image container size
  PageController pageController = PageController(viewportFraction: 0.85);

  var _currPageValue = 0.0;
  double _scaleFactor = 0.8;
  double _height = Dimensions.pageViewContainer;

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        _currPageValue = pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Slider Section
        GetBuilder<PopularProductController>(
          builder: (popularProducts) {
            return popularProducts.isLoaded
                ? Container(
                    height: Dimensions.pageView,
                    child: PageView.builder(
                        controller: pageController,
                        itemCount: popularProducts.popularProductList.length,
                        itemBuilder: (context, pos) {
                          return _buildPageItem(
                              pos, popularProducts.popularProductList[pos]);
                        }),
                  )
                : CircularProgressIndicator(
                    color: AppColors.mainColor,
                  );
          },
        ),
        GetBuilder<PopularProductController>(builder: (popularProducts) {
          return DotsIndicator(
            dotsCount: popularProducts.popularProductList.isEmpty
                ? 1
                : popularProducts.popularProductList.length,
            position: _currPageValue,
            decorator: DotsDecorator(
              activeColor: AppColors.mainColor,
              size: const Size.square(9.0),
              activeSize: const Size(18.0, 9.0),
              activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
            ),
          );
        }),
        //Popular text
        Gap(Dimensions.height30),
        Container(
          margin: EdgeInsets.only(
            left: Dimensions.width30,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              BigText(text: "Recommended"),
              Gap(Dimensions.width10),
              Container(
                margin: const EdgeInsets.only(
                  bottom: 3,
                ),
                child: BigText(
                  text: ".",
                  color: Colors.black26,
                ),
              ),
              Gap(Dimensions.width10),
              Container(
                margin: const EdgeInsets.only(
                  top: 3,
                ),
                child: SmallText(
                  text: "Food Pairing",
                ),
              ),
            ],
          ),
        ),
        //List of food and images
        GetBuilder<RecommendedProductController>(builder: (recommendedProduct) {
          return recommendedProduct.isLoaded
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: recommendedProduct.recommendedProductList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(
                            RouteHelper.getRecommendedFood(index, "home"));
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: Dimensions.width20,
                          right: Dimensions.width20,
                          bottom: Dimensions.height10,
                        ),
                        child: Row(
                          children: [
                            //Image Section
                            Container(
                              width: Dimensions.listViewImg,
                              height: Dimensions.listViewImg,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radius20,
                                ),
                                color: Colors.white38,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    AppConstants.BASE_URL +
                                        AppConstants.UPLOAD_URL +
                                        recommendedProduct
                                            .recommendedProductList[index].img!,
                                  ),
                                ),
                              ),
                            ),
                            //Text Container
                            Expanded(
                              child: Container(
                                height: Dimensions.listViewTextSize,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(
                                      Dimensions.radius20,
                                    ),
                                    bottomRight: Radius.circular(
                                      Dimensions.radius20,
                                    ),
                                  ),
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: Dimensions.width10,
                                    right: Dimensions.width10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      BigText(
                                          text: recommendedProduct
                                              .recommendedProductList[index]
                                              .name!),
                                      Gap(Dimensions.height15),
                                      SmallText(
                                          text: "With chinese characteristics"),
                                      Gap(Dimensions.height15),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          IconAndTextWidget(
                                            icon: Icons.circle_sharp,
                                            text: "Normal",
                                            iconColor: AppColors.iconColor1,
                                          ),
                                          IconAndTextWidget(
                                            icon: Icons.location_on,
                                            text: "1.7KM",
                                            iconColor: AppColors.mainColor,
                                          ),
                                          IconAndTextWidget(
                                            icon: Icons.access_time_rounded,
                                            text: "32min",
                                            iconColor: AppColors.iconColor2,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  })
              : CircularProgressIndicator(
                  color: AppColors.mainColor,
                );
        })
      ],
    );
  }

  Widget _buildPageItem(int index, ProductModel popularProduct) {
    Matrix4 matrix = new Matrix4.identity();
    if (index == _currPageValue.floor()) {
      var currScale = 1 - (_currPageValue - index) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, currTrans, 0);
    } else if (index == _currPageValue.floor() + 1) {
      var currScale =
          _scaleFactor + (_currPageValue - index + 1) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1);
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, currTrans, 0);
    } else if (index == _currPageValue.floor() - 1) {
      var currScale = 1 - (_currPageValue - index) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1);
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, currTrans, 0);
    } else {
      var currScale = 0.8;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, _height * (1 - _scaleFactor) / 2, 1);
    }

    return Transform(
      transform: matrix,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Get.toNamed(RouteHelper.getPopularFood(index, "home"));
            },
            child: Container(
              height: Dimensions.pageViewContainer,
              margin: EdgeInsets.only(
                left: Dimensions.width10,
                right: Dimensions.width10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  Dimensions.radius30,
                ),
                color: index.isEven ? Color(0xff69c5df) : Color(0xff9294cc),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    AppConstants.BASE_URL +
                        AppConstants.UPLOAD_URL +
                        popularProduct.img!,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: Dimensions.pageViewTextContainer,
              margin: EdgeInsets.only(
                left: Dimensions.width30,
                right: Dimensions.width30,
                bottom: Dimensions.height30,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    Dimensions.radius20,
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xffe8e8e8),
                      blurRadius: 5.0,
                      offset: Offset(0, 5),
                    ),
                    BoxShadow(
                      color: Colors.white,
                      offset: Offset(5, 0),
                    )
                  ]),
              child: Container(
                padding: EdgeInsets.only(
                  top: Dimensions.height15,
                  left: Dimensions.width15,
                  right: Dimensions.width15,
                ),
                child: AppColumn(text: popularProduct.name!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
