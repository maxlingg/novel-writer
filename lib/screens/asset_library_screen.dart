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
              decoration: const InputDecoration(
                labelText: '搜索素材',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // 类型筛选
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
              children: [
                _buildTypeChip(AssetType.character, '人物', Icons.person),
                _buildTypeChip(AssetType.scene, '场景', Icons.location_on),
                _buildTypeChip(AssetType.item, '物品', Icons.inventory_2),
                _buildTypeChip(AssetType.concept, '概念', Icons.lightbulb),
                _buildTypeChip(AssetType.world, '世界观', Icons.public),
                _buildTypeChip(AssetType.timeline, '时间线', Icons.timeline),
                _buildTypeChip(AssetType.relation, '关系', Icons.group),
              ],
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
                          Icons.inbox_outlined,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        Text(
                          _searchQuery.isNotEmpty ? '没有找到匹配的素材' : '暂无素材',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        ElevatedButton.icon(
                          onPressed: () => _showCreateAssetDialog(context, assetService),
                          icon: const Icon(Icons.add),
                          label: const Text('创建素材'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.medium),
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

  Widget _buildTypeChip(AssetType type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.small),
      child: FilterChip(
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedType = type),
        avatar: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }

  Widget _buildAssetCard(
    BuildContext context,
    Asset asset,
    AssetService assetService,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: InkWell(
        onTap: () => _showAssetDetail(context, asset, assetService),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Row(
            children: [
              // 图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTypeIcon(asset.type),
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(width: AppSpacing.medium),

              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (asset.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xSmall),
                        child: Text(
                          asset.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (asset.tags != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.small),
                        child: Wrap(
                          spacing: 6,
                          children: asset.tags!
                              .split(',')
                              .map((tag) => Chip(
                                    label: Text(
                                      tag.trim(),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    visualDensity: VisualDensity.compact,
                                  ))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),

              // 使用次数
              Column(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    color: theme.colorScheme.outline,
                    size: 18,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${asset.usageCount}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: AppSpacing.small),

              // 操作菜单
              PopupMenuButton(
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
