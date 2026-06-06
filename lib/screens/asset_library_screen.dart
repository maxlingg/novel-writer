import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../models/asset.dart';
import '../services/asset_service.dart';

/// 素材库页面
class AssetLibraryScreen extends StatefulWidget {
  final String? projectId;

  const AssetLibraryScreen({super.key, this.projectId});

  @override
  State<AssetLibraryScreen> createState() => _AssetLibraryScreenState();
}

class _AssetLibraryScreenState extends State<AssetLibraryScreen> {
  final _searchController = TextEditingController();
  AssetType _selectedType = AssetType.character;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final assetService = context.read<AssetService>();
      assetService.loadAssets(projectId: widget.projectId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetService = context.watch<AssetService>();
    final theme = Theme.of(context);

    // 过滤素材
    final filteredAssets = _searchQuery.isNotEmpty
        ? assetService.searchAssets(
            _searchQuery,
            projectId: widget.projectId,
            type: _selectedType,
          )
        : assetService.getAssetsByType(_selectedType, projectId: widget.projectId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('素材库'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateAssetDialog(context, assetService),
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索素材...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // 类型筛选
          SizedBox(
            height: 40,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
              child: Wrap(
                spacing: AppSpacing.small,
                children: [
                  _buildTypeChip(AssetType.character, '人物'),
                  _buildTypeChip(AssetType.scene, '场景'),
                  _buildTypeChip(AssetType.item, '物品'),
                  _buildTypeChip(AssetType.concept, '概念'),
                  _buildTypeChip(AssetType.world, '世界观'),
                  _buildTypeChip(AssetType.timeline, '时间线'),
                  _buildTypeChip(AssetType.relation, '关系'),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // 素材列表
          Expanded(
            child: filteredAssets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 72,
                          color: theme.colorScheme.outline.withOpacity(0.5),
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        Text(
                          _searchQuery.isNotEmpty ? '没有找到匹配的素材' : '素材库空空如也',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          _searchQuery.isNotEmpty ? '试试其他搜索词' : '创建你的第一个素材吧',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.large),
                        ElevatedButton.icon(
                          onPressed: () => _showCreateAssetDialog(context, assetService),
                          icon: const Icon(Icons.add),
                          label: const Text('创建素材'),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.medium),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.medium,
                      crossAxisSpacing: AppSpacing.medium,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filteredAssets.length,
                    itemBuilder: (context, index) => _buildAssetCard(
                      context,
                      filteredAssets[index],
                      assetService,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(AssetType type, String label) {
    final isSelected = _selectedType == type;

    return FilterChip(
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedType = type),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildAssetCard(
    BuildContext context,
    Asset asset,
    AssetService assetService,
  ) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showAssetDetail(context, asset, assetService),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 操作菜单（右上角）
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: PopupMenuButton(
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('编辑'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline),
                          title: Text('删除'),
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditAssetDialog(context, asset, assetService);
                          break;
                        case 'delete':
                          _confirmDelete(context, asset, assetService);
                          break;
                      }
                    },
                  ),
                ),
              ),

              // 类型图标
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(AppRadius.large),
                ),
                child: Icon(
                  _getTypeIcon(asset.type),
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: AppSpacing.small),

              // 素材名称
              Text(
                asset.name,
                style: theme.textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),

              // 标签
              if (asset.tags != null && asset.tags!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.small),
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      alignment: WrapAlignment.center,
                      children: asset.tags!
                          .split(',')
                          .take(4)
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer
                                    .withOpacity(0.3),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.small),
                              ),
                              child: Text(
                                tag.trim(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // 使用次数
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 14,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${asset.usageCount}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(AssetType type) {
    switch (type) {
      case AssetType.character:
        return Icons.person;
      case AssetType.scene:
        return Icons.location_on;
      case AssetType.item:
        return Icons.inventory_2;
      case AssetType.concept:
        return Icons.lightbulb;
      case AssetType.world:
        return Icons.public;
      case AssetType.timeline:
        return Icons.timeline;
      case AssetType.relation:
        return Icons.group;
    }
  }

  void _showCreateAssetDialog(BuildContext context, AssetService assetService) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final contentController = TextEditingController();
    final tagsController = TextEditingController();
    var selectedType = _selectedType;
    var visibility = AssetVisibility.private;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
        title: const Text('创建素材'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<AssetType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: '类型'),
                  items: AssetType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getTypeName(type)),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => selectedType = value!),
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '名称'),
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: '简介'),
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: '详细内容'),
                  maxLines: 5,
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(labelText: '标签（逗号分隔）'),
                ),
                const SizedBox(height: AppSpacing.medium),
                DropdownButtonFormField<AssetVisibility>(
                  value: visibility,
                  decoration: const InputDecoration(labelText: '可见性'),
                  items: const [
                    DropdownMenuItem(value: AssetVisibility.private, child: Text('私有')),
                    DropdownMenuItem(value: AssetVisibility.project, child: Text('项目内')),
                    DropdownMenuItem(value: AssetVisibility.public, child: Text('公开')),
                  ],
                  onChanged: (value) => setDialogState(() => visibility = value!),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;

              await assetService.createAsset(
                name: nameController.text,
                description: descController.text,
                type: selectedType,
                content: contentController.text,
                tags: tagsController.text,
                visibility: visibility,
                projectId: widget.projectId,
              );

              if (mounted) Navigator.pop(dialogContext);
            },
            child: const Text('创建'),
          ),
        ],
        ),
      ),
    );
  }

  void _showEditAssetDialog(
    BuildContext context,
    Asset asset,
    AssetService assetService,
  ) {
    final nameController = TextEditingController(text: asset.name);
    final descController = TextEditingController(text: asset.description);
    final contentController = TextEditingController(text: asset.content);
    final tagsController = TextEditingController(text: asset.tags);
    var selectedType = asset.type;
    var visibility = asset.visibility;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
        title: const Text('编辑素材'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<AssetType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: '类型'),
                  items: AssetType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getTypeName(type)),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => selectedType = value!),
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '名称'),
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: '简介'),
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: '详细内容'),
                  maxLines: 5,
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(labelText: '标签（逗号分隔）'),
                ),
                const SizedBox(height: AppSpacing.medium),
                DropdownButtonFormField<AssetVisibility>(
                  value: visibility,
                  decoration: const InputDecoration(labelText: '可见性'),
                  items: const [
                    DropdownMenuItem(value: AssetVisibility.private, child: Text('私有')),
                    DropdownMenuItem(value: AssetVisibility.project, child: Text('项目内')),
                    DropdownMenuItem(value: AssetVisibility.public, child: Text('公开')),
                  ],
                  onChanged: (value) => setDialogState(() => visibility = value!),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;

              final updated = asset.copyWith(
                name: nameController.text,
                description: descController.text,
                type: selectedType,
                content: contentController.text,
                tags: tagsController.text,
                visibility: visibility,
              );

              await assetService.updateAsset(updated);
              if (mounted) Navigator.pop(dialogContext);
            },
            child: const Text('保存'),
          ),
        ],
        ),
      ),
    );
  }

  void _showAssetDetail(
    BuildContext context,
    Asset asset,
    AssetService assetService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(asset.name),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Chip(
                      label: Text(_getTypeName(asset.type)),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: AppSpacing.small),
                    Chip(
                      label: Text(_getVisibilityName(asset.visibility)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.medium),
                if (asset.description.isNotEmpty) ...[
                  Text(
                    '简介',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(asset.description),
                  const SizedBox(height: AppSpacing.medium),
                ],
                if (asset.content.isNotEmpty) ...[
                  Text(
                    '详细内容',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(asset.content),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditAssetDialog(context, asset, assetService);
            },
            child: const Text('编辑'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    Asset asset,
    AssetService assetService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除素材「${asset.name}」吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            onPressed: () async {
              await assetService.deleteAsset(asset.id);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  String _getTypeName(AssetType type) {
    switch (type) {
      case AssetType.character:
        return '人物';
      case AssetType.scene:
        return '场景';
      case AssetType.item:
        return '物品';
      case AssetType.concept:
        return '概念';
      case AssetType.world:
        return '世界观';
      case AssetType.timeline:
        return '时间线';
      case AssetType.relation:
        return '关系';
    }
  }

  String _getVisibilityName(AssetVisibility visibility) {
    switch (visibility) {
      case AssetVisibility.private:
        return '私有';
      case AssetVisibility.project:
        return '项目内';
      case AssetVisibility.public:
        return '公开';
    }
  }
}
