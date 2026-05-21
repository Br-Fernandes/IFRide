import 'package:flutter/material.dart';

class CityCard extends StatelessWidget {
  const CityCard({super.key, required this.cityName, this.onTap});

  final String cityName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.03,
              vertical: MediaQuery.of(context).size.height * 0.016,
            ),
            child: Row(
              children: [
                Image.asset(
                  "assets/map.png",
                  width: MediaQuery.of(context).size.width * 0.1,
                  height: MediaQuery.of(context).size.width * 0.1,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                Expanded(
                  child: Text(
                    cityName,
                    style: TextStyle(
                      color: const Color(0xFF0B0A0A),
                      fontSize: MediaQuery.of(context).size.width * 0.055,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: MediaQuery.of(context).size.width * 0.06,
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }
}
